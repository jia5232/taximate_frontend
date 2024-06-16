import 'package:flutter/material.dart';
import '../../../common/const/colors.dart';
import 'complete_registration_screen.dart';

class PasswordInputScreen extends StatefulWidget {
  final String university;
  final String email;
  final String nickname;

  PasswordInputScreen({required this.university, required this.email, required this.nickname});

  @override
  _PasswordInputScreenState createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;

  void _validatePasswords() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;

      if (_passwordController.text.length < 6) {
        _passwordError = '최소 6자 이상 입력해 주세요';
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = '비밀번호가 일치하지 않습니다';
      }
    });
  }

  void _onNextPressed() {
    _validatePasswords();

    if (_formKey.currentState!.validate() && _passwordError == null && _confirmPasswordError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteRegistrationScreen(
            university: widget.university,
            email: widget.email,
            nickname: widget.nickname,
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 입력'),
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
                '비밀번호를 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '로그인 시 사용하실 비밀번호를 입력해 주세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
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
                  labelText: '비밀번호',
                  errorText: _passwordError,
                ),
                obscureText: true,
                onChanged: (value) => _validatePasswords(),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
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
                  labelText: '비밀번호 확인',
                  errorText: _confirmPasswordError,
                ),
                obscureText: true,
                onChanged: (value) => _validatePasswords(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onNextPressed,
                child: Text('다음'),
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
      ),
    );
  }
}
