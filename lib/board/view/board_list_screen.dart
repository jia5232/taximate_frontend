import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/board/component/board_list_card.dart';
import 'package:taximate/board/provider/board_list_state_notifier_provider.dart';
import '../../common/const/colors.dart';
import '../../common/layout/default_layout.dart';
import '../../common/model/cursor_pagination_model.dart';
import 'package:taximate/post/model/post_model.dart';

class BoardListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'boardList';

  const BoardListScreen({super.key});

  @override
  ConsumerState<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen> {
  final ScrollController controller = ScrollController();

  void scrollListener() {
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(boardListStateNotifierProvider.notifier).paginate(fetchMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
    Future.microtask(() {
      ref.read(boardListStateNotifierProvider.notifier).paginate();
    });
  }

  @override
  void dispose() {
    controller.removeListener(scrollListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(boardListStateNotifierProvider);

    return DefaultLayout(
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Top(),
            Expanded(
              child: _buildBoardList(data, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardList(CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    if (data is CursorPaginationModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      print(data.message);
      return const Center(
        child: Text("데이터를 불러올 수 없습니다."),
      );
    }

    if (data is CursorPaginationModel && data.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 10),
            const Text(
              "참여중인 모임이 없습니다.",
              style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 16.0),
            ),
          ],
        ),
      );
    }

    final cp = data as CursorPaginationModel;

    return RefreshIndicator(
      color: PRIMARY_COLOR,
      onRefresh: () async {
        ref.read(boardListStateNotifierProvider.notifier).lastPostId = 0;
        ref.read(boardListStateNotifierProvider.notifier).paginate(forceRefetch: true);
      },
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Center(
              child: cp is CursorPaginationModelFetchingMore
                  ? const CircularProgressIndicator(
                color: PRIMARY_COLOR,
              )
                  : const Padding(
                padding: EdgeInsets.only(top: 16.0),
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

          final pItem = cp.data[index]; //여기는 boardListModel

          return GestureDetector(
            child: BoardListCard.fromModel(boardListModel: pItem),
            onTap: () {
              final postModel = PostModel.fromBoardListModel(pItem);
              context.pushNamed(
                'boardDetail',
                extra: postModel, // Convert BoardListModel to PostModel
              );
            },
          );
        },
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12.0),
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
      child: const Row(
        children: [
          Text(
            '참여중인 모임',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
