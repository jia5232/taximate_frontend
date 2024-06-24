import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/common/const/colors.dart';
import 'package:taximate/common/provider/dio_provider.dart';
import 'package:taximate/common/component/notice_popup_dialog.dart';
import '../../../common/const/data.dart';
import '../login_screen.dart';

class CompleteRegistrationScreen extends ConsumerStatefulWidget {
  final String university;
  final String email;
  final String nickname;
  final String password;

  CompleteRegistrationScreen({
    required this.university,
    required this.email,
    required this.nickname,
    required this.password,
  });

  @override
  _CompleteRegistrationScreenState createState() => _CompleteRegistrationScreenState();
}

class _CompleteRegistrationScreenState extends ConsumerState<CompleteRegistrationScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registerUser();
  }

  Future<void> registerUser() async {
    final dio = ref.watch(dioProvider);

    try {
      final resp = await dio.post(
        'http://$ip/signup',
        data: {
          'email': widget.email,
          'password': widget.password,
          'nickname': widget.nickname,
          'univName': widget.university,
          'isAccept': true,
          'isEmailAuthenticated': true,
        },
      );
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
    } catch (e) {
      getNoticeDialog(context, "회원가입에 실패했습니다.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 완료'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '회원가입이 완료되었습니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '대학교: ${widget.university}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '이메일: ${widget.email}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '닉네임: ${widget.nickname}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('메인 페이지로 돌아가기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: PRIMARY_COLOR,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
