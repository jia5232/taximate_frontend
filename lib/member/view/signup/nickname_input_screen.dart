import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/const/colors.dart';
import '../../../common/const/data.dart';
import '../../../common/provider/dio_provider.dart';
import 'password_input_screen.dart';

class NicknameInputScreen extends ConsumerStatefulWidget {
  final String university;
  final String email;

  NicknameInputScreen({required this.university, required this.email});

  @override
  _NicknameInputScreenState createState() => _NicknameInputScreenState();
}

class _NicknameInputScreenState extends ConsumerState<NicknameInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  bool isNicknameValid = false;
  bool isCheckingNickname = false;
  bool isAcceptPersonalInfo = false;
  bool isAcceptServiceRules = false;

  Future<void> checkNickname(String nickname) async {
    final dio = ref.watch(dioProvider);

    try {
      final resp = await dio.get(
        '$awsIp/nicknameExists',
        queryParameters: {'nickname': nickname},
      );
      setState(() {
        isNicknameValid = !resp.data;
        isCheckingNickname = false;
      });

      if (isNicknameValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용 가능한 닉네임입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 사용중인 닉네임입니다.')),
        );
      }
    } catch (e) {
      setState(() {
        isCheckingNickname = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임 확인에 실패했습니다.')),
      );
    }
  }

  void _onCheckNicknamePressed() {
    if (_nicknameController.text.isNotEmpty) {
      setState(() {
        isCheckingNickname = true;
      });
      checkNickname(_nicknameController.text);
    }
  }

  void _onNextPressed() {
    if (isNicknameValid && isAcceptPersonalInfo && isAcceptServiceRules) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordInputScreen(
            university: widget.university,
            email: widget.email,
            nickname: _nicknameController.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임 중복 확인과 모든 규정 동의를 완료해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 입력'),
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
                '닉네임을 입력 해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '사용하실 닉네임을 입력해 주세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nicknameController,
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
                  labelText: '닉네임',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해 주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isCheckingNickname ? null : _onCheckNicknamePressed,
                child: Text('닉네임 확인'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      isCheckingNickname ? Colors.grey : PRIMARY_COLOR,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: PRIMARY_COLOR,
                    value: isAcceptPersonalInfo,
                    onChanged: (bool? value) {
                      setState(() {
                        isAcceptPersonalInfo = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text('개인정보 수집 및 이용 동의'),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text('개인정보 수집 및 이용동의 관련 내용'),
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
                    child: Text(
                      '내용 확인',
                      style: TextStyle(color: PRIMARY_COLOR),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: PRIMARY_COLOR,
                    value: isAcceptServiceRules,
                    onChanged: (bool? value) {
                      setState(() {
                        isAcceptServiceRules = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text('서비스 이용 규칙 동의'),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text('서비스 이용 규칙 관련 내용'),
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
                    child: Text(
                      '내용 확인',
                      style: TextStyle(color: PRIMARY_COLOR),
                    ),
                  ),
                ],
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
