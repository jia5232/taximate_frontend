import 'package:flutter/material.dart';
import '../../../common/const/colors.dart';
import 'nickname_input_screen.dart';

class AuthCodeInputScreen extends StatefulWidget {
  final String university;
  final String email;
  final String authNumber;

  AuthCodeInputScreen({required this.university, required this.email, required this.authNumber});

  @override
  _AuthCodeInputScreenState createState() => _AuthCodeInputScreenState();
}

class _AuthCodeInputScreenState extends State<AuthCodeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authCodeController = TextEditingController();
  bool isEmailVerified = false;
  bool isLoading = false;

  void verifyAuthCode() {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isEmailVerified = _authCodeController.text == widget.authNumber;
      isLoading = false;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호가 일치합니다.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NicknameInputScreen(
            university: widget.university,
            email: widget.email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호가 일치하지 않습니다.')),
      );
    }
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      verifyAuthCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('인증번호 입력'),
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
                '인증번호를 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '이메일로 전송된 인증번호를 입력해 주세요.',
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
              ElevatedButton(
                onPressed: isLoading ? null : _onVerifyPressed,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('인증번호 확인'),
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
