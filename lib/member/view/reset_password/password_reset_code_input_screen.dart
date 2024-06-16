import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/const/colors.dart';
import '../../../common/component/notice_popup_dialog.dart';
import '../../../common/const/data.dart';
import '../../../common/provider/dio_provider.dart';

class PasswordResetCodeInputScreen extends ConsumerStatefulWidget {
  final String email;
  final String authNumber;

  PasswordResetCodeInputScreen({required this.email, required this.authNumber});

  @override
  _PasswordResetCodeInputScreenState createState() => _PasswordResetCodeInputScreenState();
}

class _PasswordResetCodeInputScreenState extends ConsumerState<PasswordResetCodeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

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

  Future<void> resetPassword(String email, String newPassword) async {
    final dio = ref.watch(dioProvider);

    setState(() {
      isLoading = true;
    });

    try {
      final resp = await dio.post(
        'http://$apiServerBaseUrl/api/password/reset/confirm',
        data: {'email': email, 'newPassword': newPassword},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      setState(() {
        isLoading = false;
      });

      if (resp.statusCode == 200) {
        Navigator.pop(context); // Close this screen
        Navigator.pop(context); // Close the previous screen (email input)
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

  void _onResetPressed() {
    if (_formKey.currentState!.validate()) {
      if (_authCodeController.text == widget.authNumber) {
        resetPassword(widget.email, _passwordController.text);
      } else {
        getNoticeDialog(context, '인증번호가 일치하지 않습니다.');
      }
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
                '인증번호와 새 비밀번호를 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '이메일로 전송된 인증번호와 새로운 비밀번호를 입력해 주세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _authCodeController,
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
                  labelText: '인증번호 입력',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '인증번호를 입력해 주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
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
                  labelText: '새 비밀번호',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해 주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자리 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _onResetPressed,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('비밀번호 재설정'),
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
