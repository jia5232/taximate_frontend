import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/chat/component/chat_notice.dart';
import 'package:taximate/chat/component/others_chat_message.dart';
import 'package:taximate/chat/provider/post_info_state_notifier_provider.dart';
import 'package:taximate/chat/provider/scroll_to_bottom_button_provider.dart';
import 'package:taximate/common/const/colors.dart';
import 'package:taximate/common/dio/secure_storage.dart';

import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/provider/dio_provider.dart';
import '../../member/model/member_model.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../../post/model/post_model.dart';
import '../component/my_chat_message.dart';
import '../model/message_response_model.dart';
import '../provider/chat_history_provider.dart';
import '../provider/chat_room_id_provider.dart';
import '../provider/chat_room_state_notifier_provider.dart';
import '../provider/web_socket_state_notifier_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chat';

  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAsync();
  }


  void _initAsync() async {
    await loadPostInfo();

    final chatRoomId = ref.read(chatRoomIdProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final accessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);

    if (accessToken == null) {
      ref.read(memberStateNotifierProvider.notifier).logout();
      return;
    }
    ref.read(webSocketStateProvider.notifier).connect(accessToken, chatRoomId);

    await updateLastRead();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreMessages);
    _scrollController.dispose();
    super.dispose();
  }

  void getNoticeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: "닫기",
          onPressed: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _loadMoreMessages() {
    // reverse: true 상태에서는 스크롤이 리스트의 시작점에 도달했을 때를 감지해야 한당
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 30 &&
        !_scrollController.position.outOfRange) {
      ref.read(chatHistoryProvider.notifier).paginate(fetchMore: true);
    }
  }

  Future<void> loadPostInfo() async {
    final chatRoomId = ref.read(chatRoomIdProvider);
    final dio = ref.read(dioProvider);
    try {
      final resp = await dio.get(
        'http://$apiServerBaseUrl/posts/info/$chatRoomId',
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      if (resp.statusCode == 200) {
        final postModel = PostModel.fromJson(resp.data);
        ref.read(postInfoProvider.notifier).setPost(postModel);
      } else {
        print("${resp.statusCode}: ${resp.data}");
      }
    } catch (e) {
      getNoticeDialog(context, "오류가 발생했습니다.");
    }
  }

  // 해당 채팅방에서 마지막에 존재한 시간을 업데이트
  Future<void> updateLastRead() async {
    final chatRoomId = ref.read(chatRoomIdProvider);
    final dio = ref.read(dioProvider);
    try {
      final resp = await dio.put(
        'http://$commonServerBaseUrl/chatrooms/update-last-read/$chatRoomId',
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      if (resp.statusCode != 200) {
        print("${resp.statusCode}: ${resp.data}");
      }
    } catch (e) {
      getNoticeDialog(context, "오류가 발생했습니다.");
    }
  }

  void noticeBeforeLeaveDialog(BuildContext context) async {
    final chatRoomId = ref.read(chatRoomIdProvider);
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "모임에서 정말 나가시겠습니까?",
          buttonText: "나가기",
          onPressed: () async {
            try {
              // web socket 연결 끊기
              ref.read(webSocketStateProvider.notifier).disconnect();

              // 서버에 채팅방 나가기 요청 보내기
              final dio = ref.read(dioProvider);
              final resp = await dio.delete(
                "http://$commonServerBaseUrl/chatrooms/leave/$chatRoomId",
                options: Options(
                  headers: {
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                context.go('/?tabIndex=1');

                // 인덱스 1로 이동할때 상태관리 반영 안되는 오류해결용..
                ref
                    .read(chatRoomStateNotifierProvider.notifier)
                    .resetLastPostId(); //lastPostId 초기화
                ref
                    .read(chatRoomStateNotifierProvider.notifier)
                    .paginate(forceRefetch: true);
              }
            } catch (e) {
              getNoticeDialog(context, "오류가 발생했습니다.");
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(chatHistoryProvider);
    final showButton = ref.watch(showScrollToBottomButtonProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Top(context),
            _buildTitle(context, ref),
            Expanded(
              child: Stack(
                children: [
                  _buildChatList(data, ref, context),
                  if(showButton) _buildScrollToBottomButton(),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.0,
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: PRIMARY_COLOR,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: BODY_TEXT_COLOR,
                            ),
                          ),
                          hintText: "메시지 입력",
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  SizedBox(
                    height: 50.0,
                    child: TextButton(
                      onPressed: () {
                        _handleSubmitted(_textEditingController.text);
                      },
                      child: Text("전송"),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, WidgetRef ref) {
    final texyStyle = TextStyle(
      fontSize: 14.0,
    );

    final post = ref.watch(postInfoProvider);

    if (post != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    post.depart,
                    style: texyStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16.0,
                    ),
                  ),
                  Text(
                    post.arrive,
                    style: texyStyle,
                  ),
                  SizedBox(width: 4.0),
                  Icon(
                    Icons.person,
                    color: PRIMARY_COLOR,
                    size: 18.0,
                  ),
                  Text(post.nowMember.toString()),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${post.departTime.split(" ")[0]}일 ${post.departTime.split(" ")[1]}분 출발',
                    style: texyStyle,
                  ),
                  // Text('13:00 만남'),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildChatList(
      CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    final data = ref.watch(chatHistoryProvider);

    if (data is CursorPaginationModelLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      print(data.message);
      print(data.toString());
      print(data.runtimeType);
      return Center(
        child: Text("데이터를 불러올 수 없습니다."),
      );
    }

    final cp = data as CursorPaginationModel;

    return NotificationListener<ScrollNotification>(
      onNotification: (event) {
        final showButton = ref.read(showScrollToBottomButtonProvider.notifier);
        if (event is ScrollNotification) {
          if (_scrollController.offset != _scrollController.position.minScrollExtent) {
            // 스크롤이 최하단에 도달하지 않았을 때
            showButton.state = true; // 맨 아래로 가기 버튼 표시.
          } else {
            // 스크롤이 최하단에 도달했을 때
            showButton.state = false; // 맨 아래로 가기 버튼 숨기기.
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: cp.data.length,
        reverse: true,
        itemBuilder: (context, index) {
          final message = cp.data[index];
          return _buildChatMessage(context, message);
        },
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, MessageResponseModel message) {
    final memberState = ref.watch(memberStateNotifierProvider);
    String nickname = "";

    if (message.type == 'ENTER' || message.type == 'LEAVE') {
      return ChatNotice(content: message.content);
    }

    if (memberState is MemberModel) {
      nickname = memberState.nickname;
    }

    if (message.nickname == nickname) {
      return MyChatMessage(
        content: message.content,
        nickname: message.nickname,
        createdTime: message.createdTime,
      );
    } else {
      return OthersChatMessage(
        content: message.content,
        nickname: message.nickname,
        createdTime: message.createdTime,
      );
    }
  }

  Widget _buildScrollToBottomButton() {
    final showButton = ref.watch(showScrollToBottomButtonProvider);
    if (!showButton) return SizedBox.shrink(); // 버튼을 숨긴다.

    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: _scrollToBottom,
        child: Icon(Icons.arrow_downward),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) {
      return; // 빈 메시지는 전송하지 않음
    }

    print(text);
    _textEditingController.clear();

    final chatRoomId = ref.read(chatRoomIdProvider); // 현재 채팅방 ID
    ref.read(webSocketStateProvider.notifier).sendMessage(chatRoomId, text);
    updateLastRead();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // 스크롤이 필요한지 확인
    if (_scrollController.hasClients) {
      // 현재 프레임이 렌더링된 후에 실행될 콜백을 스케줄링
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _Top(BuildContext context) {
    final post = ref.watch(postInfoProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            // 해당 채팅방에서 마지막에 존재한 시간을 업데이트
            await updateLastRead();

            // web socket 연결 끊기
            ref.read(webSocketStateProvider.notifier).disconnect();

            // bottom Navigator bar 인덱스 1번으로 가게함.
            context.go('/?tabIndex=1');

            // 인덱스 1로 이동할때 상태관리 반영 안되는 오류해결용..
            ref
                .read(chatRoomStateNotifierProvider.notifier)
                .resetLastPostId(); //lastPostId 초기화
            ref
                .read(chatRoomStateNotifierProvider.notifier)
                .paginate(forceRefetch: true);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        if (post?.isAuthor == false) //글 작성자가 아닌 경우에만 나갈 수 있게 한다.
          IconButton(
            onPressed: () {
              noticeBeforeLeaveDialog(context);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}
