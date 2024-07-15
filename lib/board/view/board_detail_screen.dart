import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taximate/post/model/post_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../common/provider/dio_provider.dart';
import '../provider/board_list_state_notifier_provider.dart';
import '../provider/savings_provider.dart';

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
              final resp = await dio.post(
                "$awsIp/posts/leave/${widget.post.id}",
                options: Options(
                  headers: {
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                ref.refresh(boardListStateNotifierProvider);
                ref.refresh(savingsProvider);
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

  void reportPost(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "해당 글을 신고하시겠습니까? 신고 사항은 24시간 내에 처리됩니다.",
          buttonText: "신고하기",
          onPressed: (){
            onContactPressed(context);
          },
        );
      },
    );
  }

  void onContactPressed(BuildContext context) async {
    final Email email = Email(
        body: '문의할 사항을 아래에 작성해주세요.',
        subject: '[택시메이트 문의]',
        recipients: ['99jiasmin@gmail.com'],
        cc: [],
        bcc: [],
        attachmentPaths: [],
        isHTML: false);

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      String message = '기본 메일 앱을 사용할 수 없습니다. \n이메일로 연락주세요! 99jiasmin@gmail.com';
      getNoticeDialog(context, message);
    }
  }

  void blockMember(BuildContext context, int authorId){
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "방장을 차단하시겠습니까? 앞으로 이 유저가 개최한 모임을 볼 수 없습니다.",
          buttonText: "차단하기",
          onPressed: () async {
            try {
              final dio = ref.read(dioProvider);
              final resp = await dio.post(
                "$awsIp/block/$authorId",
                options: Options(
                  headers: {
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return NoticePopupDialog(
                      message: "차단이 완료되었습니다.",
                      buttonText: "닫기",
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
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
                const SizedBox(height: 20),
                if (!widget.post.isAuthor)
                  _buildReport(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: (){
            reportPost(context);
          },
          child: Text(
            '신고하기',
            style: TextStyle(color: Colors.red.shade300),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.circle,
            color: Colors.grey,
            size: 5.0,
          ),
        ),
        GestureDetector(
          onTap: (){
            blockMember(context, widget.post.authorId);
          },
          child: Text(
            '차단하기',
            style: TextStyle(color: BODY_TEXT_COLOR),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
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
          _buildLinkText(
              widget.post.openChatLink, textStyle, linkStyle, context),
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
        final url = match.group(0)!;
        spans.add(
          TextSpan(
            text: url,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.post.depart,
                style: textStyle,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16.0,
                  color: Colors.grey,
                ),
              ),
              Text(
                widget.post.arrive,
                style: textStyle,
              ),
              SizedBox(width: 8.0),
              Icon(
                Icons.person,
                color: PRIMARY_COLOR,
                size: 18.0,
              ),
              Text(
                widget.post.nowMember.toString(),
                style: textStyle,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${widget.post.departTime.split(" ")[0]}일 ${widget.post.departTime.split(" ")[1]}분 출발',
                style: textStyle.copyWith(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _Top(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              context.pop();
            },
            icon: Icon(Icons.arrow_back_ios_new),
            color: Colors.black,
          ),
          if (!widget.post.isAuthor) // 글 작성자가 아닌 경우에만 나갈 수 있게 한다.
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
      ),
    );
  }
}
