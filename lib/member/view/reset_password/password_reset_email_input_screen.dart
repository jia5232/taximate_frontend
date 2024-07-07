import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/const/colors.dart';
import 'password_reset_code_input_screen.dart';
import '../../../common/component/notice_popup_dialog.dart';
import '../../../common/const/data.dart';
import '../../../common/provider/dio_provider.dart';

class PasswordResetEmailInputScreen extends ConsumerStatefulWidget {
  @override
  _PasswordResetEmailInputScreenState createState() => _PasswordResetEmailInputScreenState();
}

class _PasswordResetEmailInputScreenState extends ConsumerState<PasswordResetEmailInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
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

  Future<void> sendResetEmail(String email) async {
    final dio = ref.watch(dioProvider);

    setState(() {
      isLoading = true;
    });

    try {
      final resp = await dio.post(
        '$awsIp/api/password/reset/request',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (resp.statusCode == 200) {
        if (resp.data.containsKey('authNumber')) {
          authNumber = resp.data['authNumber'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordResetCodeInputScreen(
                email: email,
                authNumber: authNumber,
              ),
            ),
          );
        } else {
          getNoticeDialog(context, '알 수 없는 오류가 발생했습니다.');
        }
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
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  void _onSendPressed() {
    if (_formKey.currentState!.validate()) {
      sendResetEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 재설정'),
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
                '이메일을 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '비밀번호를 재설정할 이메일을 입력해 주세요.',
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
                  backgroundColor: isLoading ? Colors.grey : PRIMARY_COLOR,
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
