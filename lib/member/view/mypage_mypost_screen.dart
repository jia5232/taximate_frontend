import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/common/layout/default_layout.dart';

import '../../chat/provider/chat_room_id_provider.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/provider/dio_provider.dart';
import '../../post/component/post_card.dart';
import '../../post/component/post_popup_dialog.dart';
import '../../post/provider/my_post_state_notifier_provider.dart';
import '../../post/provider/post_repository_provider.dart';
import '../../post/view/post_update_form_screen.dart';

class MyPageMyPostScreen extends ConsumerStatefulWidget {
  const MyPageMyPostScreen({super.key});

  @override
  ConsumerState<MyPageMyPostScreen> createState() => _MyPageMyPostScreenState();
}

class _MyPageMyPostScreenState extends ConsumerState<MyPageMyPostScreen> {
  final ScrollController controller = ScrollController();

  void scrollListener() {
    // 현재 위치가 최대 길이보다 조금 덜되는 위치까지 왔다면 새로운 데이터를 추가 요청.
    // 현재 컨트롤러 위치가(controller.offset) 컨트롤러의 최대 크기 - n 보다 크면 요청을 보낸다.
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(myPostStateNotifierProvider.notifier).paginate(fetchMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
    Future.microtask(
        () => ref.read(myPostStateNotifierProvider.notifier).paginate());
  }

  void noticeBeforeDeleteDialog(BuildContext context, int postId) async {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "정말 삭제하시겠습니까?",
          buttonText: "삭제하기",
          onPressed: () async {
            final dio = ref.read(dioProvider);
            try {
              final resp = await dio.delete(
                "http://$apiServerBaseUrl/posts/$postId",
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                Navigator.pop(context);
                Navigator.pop(context);
                ref.refresh(myPostStateNotifierProvider);
              }
            } on DioException catch (e) {
              Navigator.pop(context);
              Navigator.pop(context);
              showDialog( // 새로운 팝업 표시
                context: context,
                builder: (context) {
                  return NoticePopupDialog(
                    message: e.response?.data["message"] ?? "에러 발생",
                    buttonText: "닫기",
                    onPressed: () {
                      Navigator.pop(context); // 두 번째 팝업 닫기
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(myPostStateNotifierProvider);

    return DefaultLayout(
      child: SafeArea(
        child: Column(
          children: [
            _Top(),
            SizedBox(height: 14.0),
            Expanded(
              child: _buildPostList(data, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(
      CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    final data = ref.watch(myPostStateNotifierProvider);
    //postStateNotifierProvider가 postRepository에서 받아온 값을 그대로 돌려주므로 Future builder가 필요없어짐..

    if (data is CursorPaginationModelLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      return Center(
        child: Text("데이터를 불러올 수 없습니다."),
      );
    }

    final cp = data as CursorPaginationModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Center(
              child: cp is CursorPaginationModelFetchingMore
                  ? CircularProgressIndicator(
                      color: PRIMARY_COLOR,
                    )
                  : Text(
                      'Copyright 2024. JiaKwon all rights reserved.\n',
                      style: TextStyle(
                        color: BODY_TEXT_COLOR,
                        fontSize: 12.0,
                      ),
                    ),
            );
          }

          final pItem = cp.data[index];

          return GestureDetector(
            child: PostCard.fromModel(postModel: pItem),
            onTap: () async {
              final detailedPostModel = await ref
                  .read(postRepositoryProvider)
                  .getPostDetail(id: pItem.id);
              //getPostDetail에서 api요청해서 가져오고, PostModel로 변환한다. (retrofit)
              // final detailedPostModel = await getPostDetail(ref, pItem.id);
              showDialog(
                context: context,
                builder: (context) {
                  return PostPopupDialog(
                    id: pItem.id,
                    isFromSchool: detailedPostModel.isFromSchool,
                    depart: detailedPostModel.depart,
                    arrive: detailedPostModel.arrive,
                    departTime: detailedPostModel.departTime,
                    maxMember: detailedPostModel.maxMember,
                    nowMember: detailedPostModel.nowMember,
                    cost: detailedPostModel.cost,
                    isAuthor: detailedPostModel.isAuthor,
                    joinOnPressed: () {
                      ref.read(chatRoomIdProvider.notifier).state = detailedPostModel.chatRoomId;
                      context.goNamed('chat');
                    },
                    deleteOnPressed: () {
                      noticeBeforeDeleteDialog(context, pItem.id);
                    },
                    updateOnPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostUpdateFormScreen(
                            postId: pItem.id,
                            isMypageUpdate: true,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: 16.0);
        },
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 90),
        const Text(
          '내가 작성한 글',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
