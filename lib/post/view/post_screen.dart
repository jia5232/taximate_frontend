import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/board/provider/board_list_state_notifier_provider.dart';
import 'package:taximate/common/const/colors.dart';
import 'package:taximate/common/layout/default_layout.dart';
import 'package:taximate/common/model/cursor_pagination_model.dart';
import 'package:taximate/common/provider/dio_provider.dart';
import 'package:taximate/post/component/post_popup_dialog.dart';
import 'package:taximate/post/provider/post_repository_provider.dart';
import 'package:taximate/post/provider/post_screen_provider.dart';
import 'package:taximate/post/provider/post_state_notifier_provider.dart';
import 'package:taximate/post/provider/university_short_name_provider.dart';
import 'package:taximate/post/view/post_form_screen.dart';
import 'package:taximate/post/view/post_update_form_screen.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/data.dart';
import '../../member/model/member_model.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../component/post_card.dart';
import '../model/post_model.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final ScrollController controller = ScrollController();

  void toggleSelect(WidgetRef ref, int value) {
    ref.read(fromSchoolProvider.notifier).state = value == 0;
    ref.read(postStateNotifierProvider.notifier).lastPostId = 0;
    ref.read(postStateNotifierProvider.notifier).paginate(forceRefetch: true);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(postStateNotifierProvider.notifier).paginate(
            fetchMore: true,
          );
    }
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
                "$awsIp/posts/$postId",
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
                ref.refresh(postStateNotifierProvider);
              }
            } on DioException catch (e) {
              Navigator.pop(context);
              Navigator.pop(context);
              getNoticeDialog(
                context,
                e.response?.data["message"] ?? "에러 발생",
              );
            }
          },
        );
      },
    );
  }

  Future<void> joinPost(int postId, PostModel detailedPostModel) async {
    final dio = ref.read(dioProvider);
    try {
      final resp = await dio.post(
        "$awsIp/posts/join/$postId",
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      if (resp.statusCode == 200) {
        final pItem = await ref
            .read(postRepositoryProvider)
            .getPostDetail(id: detailedPostModel.id);
        ref.refresh(boardListStateNotifierProvider);
        context.pushNamed(
          'boardDetail',
          extra: pItem,
        );
      }
    } on DioException catch (e) {
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
  }

  Future<void> leavePost(int postId) async {
    final dio = ref.read(dioProvider);
    try {
      final resp = await dio.post(
        "$awsIp/posts/leave/$postId",
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      if (resp.statusCode == 200) {
        ref
            .refresh(postStateNotifierProvider.notifier)
            .paginate(forceRefetch: true);
      }
    } on DioException catch (e) {
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
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(postStateNotifierProvider);

    return DefaultLayout(
      child: SafeArea(
        child: Column(
          children: [
            _buildTop(ref, context),
            _buildToggleButton(ref, context),
            _buildTextFormField(ref, context),
            SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: PRIMARY_COLOR,
                onRefresh: () async {
                  ref.read(postStateNotifierProvider.notifier).lastPostId = 0;
                  ref
                      .read(postStateNotifierProvider.notifier)
                      .paginate(forceRefetch: true);
                },
                child: CustomScrollView(
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildPostList(data, ref, context),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Copyright 2024. JiaKwon all rights reserved.\n',
                          style: TextStyle(
                            color: BODY_TEXT_COLOR,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(WidgetRef ref, BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);
    String univName = "";

    if (memberState is MemberModel) {
      univName = memberState.univName;
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Image.asset(
                    'asset/imgs/taximate_logo.png',
                    width: 50,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  univName,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            height: 60.0,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostFormScreen(),
                  ),
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.solidPenToSquare,
              ),
              label: const Text(
                "내가 방장",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(WidgetRef ref, BuildContext context) {
    double borderWidth = 1;

    return ToggleButtons(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('학교에서 출발'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('학교로 도착'),
        ),
      ],
      isSelected: [
        ref.watch(fromSchoolProvider),
        !ref.watch(fromSchoolProvider),
      ],
      onPressed: (value) => toggleSelect(ref, value),
      borderColor: Colors.grey[300],
      borderWidth: borderWidth,
      selectedBorderColor: Colors.black,
      fillColor: Colors.transparent,
      renderBorder: true,
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width / 2 - borderWidth * 2,
        height: 40,
      ),
      textStyle: TextStyle(fontSize: 18.0),
      selectedColor: Colors.black,
    );
  }

  Widget _buildTextFormField(WidgetRef ref, BuildContext context) {
    bool fromSchool = ref.watch(fromSchoolProvider);
    String? searchWord = ref.read(searchKeywordProvider.notifier).state;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          TextFormField(
            cursorColor: PRIMARY_COLOR,
            decoration: InputDecoration(
              hintText: fromSchool ? '도착지를 입력해주세요.' : '출발지를 입력해주세요.',
              hintStyle: TextStyle(
                color: PRIMARY_COLOR,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  size: 30.0,
                ),
                color: PRIMARY_COLOR,
                onPressed: () {
                  ref.read(searchKeywordProvider.notifier).state = searchWord;
                  ref.read(postStateNotifierProvider.notifier).lastPostId = 0;
                  ref
                      .read(postStateNotifierProvider.notifier)
                      .paginate(forceRefetch: true);
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                  color: PRIMARY_COLOR,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                  color: PRIMARY_COLOR,
                  width: 2.5,
                ),
              ),
            ),
            onChanged: (String value) {
              searchWord = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(
      CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    if (data is CursorPaginationModelLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(
            color: PRIMARY_COLOR,
          ),
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text("데이터를 불러올 수 없습니다."),
        ),
      );
    }

    if (data is CursorPaginationModel && data.data.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            const Text(
              "게시글이 없습니다.",
              style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 16.0),
            ),
          ],
        ),
      );
    }

    final cp = data as CursorPaginationModel;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index.isOdd) {
              return SizedBox(height: 16.0);
            }

            final itemIndex = index ~/ 2;
            if (itemIndex >= cp.data.length) {
              return Center(
                child: cp is CursorPaginationModelFetchingMore
                    ? CircularProgressIndicator(
                        color: PRIMARY_COLOR,
                      )
                    : SizedBox.shrink(),
              );
            }

            final pItem = cp.data[itemIndex];

            return GestureDetector(
              onTap: pItem.nowMember == pItem.maxMember
                  ? null
                  : () async {
                      // 수정
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
                            joinOnPressed: () async {
                              final dio = ref.read(dioProvider);
                              try {
                                final resp = await dio.get(
                                  '$awsIp/posts/is-joined/${pItem.id}',
                                  options: Options(
                                    headers: {
                                      'accessToken': 'true',
                                    },
                                  ),
                                );
                                final isMemberJoinedPost = resp.data;
                                if (!isMemberJoinedPost) {
                                  await joinPost(pItem.id, detailedPostModel);
                                } else {
                                  ref
                                      .read(postRepositoryProvider)
                                      .getPostDetail(id: pItem.id);
                                  ref.refresh(boardListStateNotifierProvider);
                                  context.pushNamed(
                                    'boardDetail',
                                    extra: detailedPostModel,
                                  );
                                }
                              } on DioException catch (e) {
                                getNoticeDialog(
                                  context,
                                  e.response?.data["message"] ?? "에러 발생",
                                );
                              }
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
                                    isMypageUpdate: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
              child: PostCard.fromModel(postModel: pItem),
            );
          },
          childCount: cp.data.length * 2,
        ),
      ),
    );
  }
}
