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

  final String privacyPolicy = '''
  1. 개인정보의 수집 및 이용에 대한 동의
  
가. 수집 및 이용 목적
- 택시메이트가 제공하는 커뮤니티 서비스 이용에 필요
- 대학교 재학여부 및 본인 확인을 위하여 필요한 최소한의 범위 내에서 개인정보를 수집하고 있습니다.

나. 수집 및 이용 항목
- 필수항목 : 성명, 닉네임, 전자우편, 대학교 이름
- 선택항목 : 없음

다. 개인정보의 보유 및 이용 기간
- 이용자의 개인정보 수집ᆞ이용에 관한 동의일로부터 채용절차 종료 시까지 위 이용목적을 위하여 보유 및 이용하게 됩니다. 단, 서비스 종료 후에는 분쟁 해결 및 법령상 의무이행 등을 위하여 1년간 보유하게 됩니다.

라. 동의를 거부할 권리 및 동의를 거부할 경우의 불이익
- 위 개인정보 중 필수정보의 수집ᆞ이용에 관한 동의는 서비스 이용을 위해 필수적이므로, 위 사항에 동의하셔야만 서비스의 이용이 가능합니다.
- 지원자는 개인정보의 선택항목 제공 동의를 거부할 권리가 있습니다. 다만, 지원자가 선택항목 동의를 거부하는 경우 원활한 정보 확인을 할 수 없어 서비스 이용에 제한받을 수 있습니다.

2. 민감정보 수집에 대한 동의 (민감정보 기재 시에만 한함)
가. 해당 사항 없음

3. 개인정보의 제3자 제공에 대한 동의
가. 해당사항없음

나는 택시메이트가 위와 같이 개인정보를 수집ᆞ이용하는 것에 동의합니다.
  ''';

  final String servicePolicy = '''
  택시메이트는 안전하고 즐거운 서비스 운영을 위해 서비스 운영 규칙을 제정하여 운영하고 있습니다.
  
  1. 불법, 도박, 음란물, 도배, 욕설, 자살 관련 표현 등 사용자들에게 불쾌감을 줄 수 있는 부적절한 모든 컨텐츠(글, 댓글, 사진 등)를 생성하지 않도록 유의해주세요.
  위반 시 게시글이 삭제되고 서비스 이용이 제한될 수 있으며, 관련된 법적 문제 발생시 철저한 불관용 원칙을 적용합니다.
  
  2. 본 플랫폼 택시메이트는 동일한 출발지에서 동일한 목적지로 가기 위한 사용자들의 네트워킹에만 관여하며, 사용자간의 금전 거래, 사기 행위 등 부적절한 행위로 인한 어떤 피해도 책임지지 않습니다. 유의해주세요.

  3. 본 플랫폼 택시메이트는 사용자의 웹메일 인증을 기반으로 운영되므로 부적절한 사건 발생시 민사 및 형사 처벌을 받을 수 있습니다. 또한 이를 위해 탈퇴후에도 3년간 회원의 이메일 정보를 보관합니다.
  
  나는 택시메이트가 위와 같이 서비스 운영 규칙을 제정하여 적용하는 것에 대해 동의합니다.
  ''';

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
                            content: SingleChildScrollView(
                              child: Text(
                                privacyPolicy,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                                softWrap: true,
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_COLOR,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Center(
                                  child: Text(
                                    '닫기',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                            content: SingleChildScrollView(
                              child: Text(
                                servicePolicy,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                                softWrap: true,
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_COLOR,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Center(
                                  child: Text(
                                    '닫기',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
