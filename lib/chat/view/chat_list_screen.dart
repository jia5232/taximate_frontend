import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/chat/component/chat_room_card.dart';
import 'package:taximate/chat/provider/chat_room_state_notifier_provider.dart';

import '../../common/const/colors.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../provider/chat_room_id_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chatList';

  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final ScrollController controller = ScrollController();

  void scrollListener() {
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(chatRoomStateNotifierProvider.notifier).paginate(fetchMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(chatRoomStateNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Top(),
            Expanded(
              child: _buildChatRoomList(data, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomList(CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
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

    if (data is CursorPaginationModel && data.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height/10),
            const Text(
              "참여중인 채팅방이 없습니다.",
              style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 16.0),
            ),
          ],
        ),
      );
    }

    final cp = data as CursorPaginationModel;

    return ListView.builder(
      controller: controller,
      itemCount: cp.data.length + 1,
      itemBuilder: (_, index) {
        if (index == cp.data.length) {
          return Center(
            child: cp is CursorPaginationModelFetchingMore
                ? CircularProgressIndicator(
              color: PRIMARY_COLOR,
            )
                : Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Copyright 2024. JiaKwon all rights reserved.\n',
                style: TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 12.0,
                ),
              ),
            ),
          );
        }

        final pItem = cp.data[index];

        return GestureDetector(
          child: ChatRoomCard.fromModel(chatRoomModel: pItem),
          onTap: () {
            ref.read(chatRoomIdProvider.notifier).state = pItem.chatRoomId;
            context.goNamed('chat');
          },
        );
      },
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Row(
        children: [
          Text(
            '채팅',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
