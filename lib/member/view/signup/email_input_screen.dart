import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/const/colors.dart';
import 'auth_code_input_screen.dart';
import '../../../common/component/notice_popup_dialog.dart';
import '../../../common/const/data.dart';
import '../../../common/provider/dio_provider.dart';

class EmailInputScreen extends ConsumerStatefulWidget {
  final String university;

  EmailInputScreen({required this.university});

  @override
  _EmailInputScreenState createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends ConsumerState<EmailInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool isEmailSend = false;
  bool isLoading = false;
  String authNumber = '';

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

  Future<void> sendVerificationEmail(String email) async {
    final dio = ref.watch(dioProvider);

    setState(() {
      isLoading = true;
    });

    try {
      final suffixResponse = await dio.post(
        'http://$apiServerBaseUrl/validateEmailSuffix',
        data: {'email': email, 'univName': widget.university},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (!suffixResponse.data) {
        setState(() {
          isLoading = false;
        });
        getNoticeDialog(context, '대학교와 이메일이 일치하지 않습니다. 올바른 학교 이메일을 입력하세요.');
        return;
      }

      final resp = await dio.post(
        'http://$apiServerBaseUrl/email',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (resp.statusCode == 200) {
        setState(() {
          isEmailSend = true;
          isLoading = false;
        });

        if (resp.data.containsKey('authNumber')) {
          authNumber = resp.data['authNumber'];
        } else {
          getNoticeDialog(context, '알 수 없는 오류가 발생했습니다.');
        }

        showDialog(
          context: context,
          builder: (context) {
            return NoticePopupDialog(
              message: "인증번호가 전송되었습니다.",
              buttonText: "닫기",
              onPressed: () {
                Navigator.pop(context); // 두 번째 팝업 닫기
              },
            );
          },
        ).then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthCodeInputScreen(
                university: widget.university,
                email: email,
                authNumber: authNumber,
              ),
            ),
          );
        });
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
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
  }

  void _onSendPressed() {
    if (_formKey.currentState!.validate()) {
      sendVerificationEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이메일 입력'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '대학교 이메일을 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '로그인 시 사용하실 학교 이메일을 입력해 주세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
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
                      color: Colors.grey,
                    ),
                  ),
                  labelText: '이메일',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '유효한 이메일을 입력해 주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _onSendPressed,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('인증번호 전송'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isLoading ? Colors.grey : Colors.orangeAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
