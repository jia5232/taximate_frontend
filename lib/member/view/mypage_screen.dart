import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/board/provider/board_list_state_notifier_provider.dart';
import 'package:taximate/common/layout/default_layout.dart';
import 'package:taximate/member/model/member_model.dart';
import 'package:taximate/member/provider/member_state_notifier_provider.dart';
import 'package:taximate/member/view/mypage_mypost_screen.dart';
import 'package:taximate/member/view/mypage_qna_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taximate/post/provider/my_post_state_notifier_provider.dart';
import 'package:taximate/post/provider/post_state_notifier_provider.dart';
import '../../board/provider/savings_provider.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/provider/dio_provider.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {

  void onMyInfoPressed(String email, String univName, String nickname) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text("내 정보"),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 32.0, right: 32.0, top: 10.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('이메일'),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Expanded(child: Text(email)),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Text('학교'),
                      const SizedBox(
                        width: 42.0,
                      ),
                      Expanded(child: Text(univName)),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Text('닉네임'),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Expanded(child: Text(nickname)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void onAppInfoPressed() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text("앱 정보"),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 32.0, right: 32.0, top: 10.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('앱 이름'),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Text('택시메이트'),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Text('앱 버전'),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Text(info.version),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void onContactPressed() async {
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
      String title = '문의하기';
      String message = '기본 메일 앱을 사용할 수 없습니다. \n이메일로 연락주세요! 99jiasmin@gmail.com';
      showNoticeAlert(title, message);
    }
  }

  void showNoticeAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            title,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 32.0, right: 32.0, top: 10.0, bottom: 10.0),
              child: Column(
                children: [
                  Text(message),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void noticeBeforeLogoutDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "정말 로그아웃 하시겠습니까?",
          buttonText: "로그아웃",
          onPressed: () {
            ref.read(memberStateNotifierProvider.notifier).logout();
            ref.refresh(boardListStateNotifierProvider);
            ref.refresh(myPostStateNotifierProvider);
            ref.refresh(postStateNotifierProvider);
          },
        );
      },
    );
  }

  Future<void> deleteMember(BuildContext context, WidgetRef ref) async {
    final dio = ref.watch(dioProvider);

    final memberState = ref.read(memberStateNotifierProvider);
    if (memberState is MemberModel) {

      final response = await dio.delete(
        "http://$ip/member",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accessToken': 'true',
          },
        ),
      );

      if (response.statusCode == 204) {
        ref.read(memberStateNotifierProvider.notifier).logout();
        ref.refresh(boardListStateNotifierProvider);
        ref.refresh(myPostStateNotifierProvider);
        ref.refresh(postStateNotifierProvider);
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return NoticePopupDialog(
              message: "탈퇴과정에서 문제가 발생했습니다. 다시 시도해주세요.",
              buttonText: "닫기",
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      }
    }
  }

  void onWithdrawPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: '정말 회원을 탈퇴하시겠습니까? 탈퇴 후에는 복구할 수 없습니다.',
          buttonText: "탈퇴하기",
          onPressed: () {
            Navigator.of(context).pop();
            deleteMember(context, ref);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);

    String nickname = "";

    if (memberState is MemberModel) {
      nickname = memberState.nickname;
    }

    return DefaultLayout(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              _Title(nickname: nickname),
              SizedBox(height: 10.0),
              _buildSavingsBox(ref),
              SizedBox(height: 20.0),
              _buildAccountInfo(ref, context),
              SizedBox(height: 40.0),
              _buildNoticeInfo(ref, context),
              SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onWithdrawPressed,
                    child: Text(
                      '회원 탈퇴',
                      style: TextStyle(color: Colors.red),
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
                    onTap: noticeBeforeLogoutDialog,
                    child: Text(
                      '로그아웃',
                      style: TextStyle(color: BODY_TEXT_COLOR),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsBox(WidgetRef ref) {
    final savingsAsyncValue = ref.watch(savingsProvider);

    return savingsAsyncValue.when(
      data: (savings) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.savings, color: Colors.lightBlueAccent, size: 30),
              SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  '택시메이트로 ${DateTime.now().month}월에 절약한 금액:\n${savings.toString()}원',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.redAccent, width: 1.5),
        ),
        child: Text(
          'Error: $error',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAccountInfo(WidgetRef ref, BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);

    String nickname = "";
    String univName = "";
    String email = "";

    if (memberState is MemberModel) {
      nickname = memberState.nickname;
      univName = memberState.univName;
      email = memberState.email;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "계정 정보",
            style: TextStyle(color: BODY_TEXT_COLOR),
          ),
        ),
        _MenuButton(
          title: "내 정보",
          onPressed: () {
            onMyInfoPressed(email, univName, nickname);
          },
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          ),
        ),
        _MenuButton(
          title: "내가 작성한 글",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MyPageMyPostScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoticeInfo(WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          width: MediaQuery.of(context).size.width,
          child: Text(
            "이용 안내",
            style: TextStyle(color: BODY_TEXT_COLOR),
          ),
        ),
        _MenuButton(
          title: "앱 정보",
          onPressed: () {
            onAppInfoPressed();
          },
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          ),
        ),
        _MenuButton(
          title: "Q&A",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MyPageQnaScreen(),
              ),
            );
          },
        ),
        _MenuButton(
          title: "문의하기",
          onPressed: () {
            onContactPressed();
          },
        ),
        _MenuButton(
          title: "서비스 이용 약관",
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('서비스 이용 약관'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text('닫기'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        _MenuButton(
          title: "개인정보 처리방침",
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('개인정보 처리 방침'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text('닫기'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'asset/imgs/taximate_logo.png',
            width: 30,
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String nickname;

  const _Title({
    required this.nickname,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반가워요 $nickname님!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            '오늘도 택시메이트로 안전하게 등하교하세요.',
            style: TextStyle(
              fontSize: 16,
              color: BODY_TEXT_COLOR,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Border? border;

  const _MenuButton({
    required this.title,
    required this.onPressed,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: border == null
              ? Border(
            top: BorderSide(color: Colors.transparent),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          )
              : border,
        ),
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.0),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 14.0,
                color: BODY_TEXT_COLOR,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
