import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/common/layout/default_layout.dart';

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

  Future<void> _refreshPosts() async {
    ref.read(myPostStateNotifierProvider.notifier).paginate(forceRefetch: true);
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
                "http://$ip/posts/$postId",
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
              showDialog(
                context: context,
                builder: (context) {
                  return NoticePopupDialog(
                    message: e.response?.data["message"] ?? "에러 발생",
                    buttonText: "닫기",
                    onPressed: () {
                      Navigator.pop(context);
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

    if (cp.data.isEmpty) {
      return Center(
        child: Text("작성한 글이 없습니다."),
      );
    }

    return RefreshIndicator(
      color: PRIMARY_COLOR,
      onRefresh: _refreshPosts,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: controller,
          physics: AlwaysScrollableScrollPhysics(),
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
                        context.goNamed('boardDetail');
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
        Center(
          child: const Text(
            '내가 작성한 글',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
