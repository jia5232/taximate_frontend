import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/post/model/post_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../common/provider/dio_provider.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'boardDetail';
  final PostModel post;

  const BoardDetailScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  void noticeBeforeLeaveDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "모임에서 정말 나가시겠습니까?",
          buttonText: "나가기",
          onPressed: () async {
            try {
              final dio = ref.read(dioProvider);
              final resp = await dio.delete(
                "http://$ip/posts/leave/${widget.post.id}",
                options: Options(
                  headers: {
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                context.go('/?tabIndex=1');
              }
            } catch (e) {
              getNoticeDialog(context, "오류가 발생했습니다.");
            }
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Center(
            child: Column(
              children: [
                _Top(context),
                _buildTitle(context),
                _buildBody(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    );

    final linkStyle = TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
      fontSize: 16.0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방장: ${widget.post.authorName}',
            style: textStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 8.0),
          _buildLinkText(widget.post.openChatLink, textStyle, linkStyle, context),
        ],
      ),
    );
  }

  Widget _buildLinkText(String text, TextStyle textStyle, TextStyle linkStyle, BuildContext context) {
    final List<InlineSpan> spans = [];
    final RegExp urlPattern = RegExp(
      r'((https?|ftp)://[^\s/$.?#].[^\s]*)',
      caseSensitive: false,
    );

    text.splitMapJoin(
      urlPattern,
      onMatch: (Match match) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = match.group(0);
                if (await canLaunch(url!)) {
                  await launch(url);
                } else {
                  getNoticeDialog(context, "해당 URL을 열 수 없습니다.");
                }
              },
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: textStyle));
        return '';
      },
    );

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14.0,
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  widget.post.depart,
                  style: textStyle,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16.0,
                  ),
                ),
                Text(
                  widget.post.arrive,
                  style: textStyle,
                ),
                SizedBox(width: 4.0),
                Icon(
                  Icons.person,
                  color: PRIMARY_COLOR,
                  size: 18.0,
                ),
                Text(widget.post.nowMember.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${widget.post.departTime.split(" ")[0]}일 ${widget.post.departTime.split(" ")[1]}분 출발',
                  style: textStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _Top(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            context.go('/?tabIndex=1');
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        if (widget.post.isAuthor == false) //글 작성자가 아닌 경우에만 나갈 수 있게 한다.
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
