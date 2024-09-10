import 'package:flutter/material.dart';
import 'package:taximate/common/layout/default_layout.dart';

import '../../common/const/colors.dart';

class MyPageQnaScreen extends StatelessWidget {
  const MyPageQnaScreen({super.key});

  Widget _QnA(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
      child: Container(
        width: 340.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
            ),
            SizedBox(height: 6.0),
            Text(
              answer,
              style: TextStyle(
                fontSize: 14.0,
                color: BODY_TEXT_COLOR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              _Top(),
              SizedBox(height: 10.0),
              _QnA(
                "Q. 택시메이트는 어떤 서비스인가요?",
                "모든 대학생을 위한 등하교 택시 공유 서비스입니다."
                    "\n원하는 지하철 역과 학교 사이를 택시로 편하게 이용하세요.",
              ),
              _QnA(
                "Q. 어떻게 이용할 수 있나요?",
                "메인 페이지에서 이미 개설된 모임에 참여할 수도 있고,"
                    "\n직접 글을 올려서 사람을 모을 수도 있습니다.",
              ),
              _QnA(
                "Q. 왜 목적지나 출발지를 역으로만 지정해야 하나요?",
                "여러 사람이 금액을 나눠내고 택시를 공유하는 만큼,"
                    "\n모두에게 공평한 목적지, 출발지를 선정하도록 했습니다.",
              ),
              _QnA(
                "Q. 신고하고 싶은 사용자가 있으면 어떻게 하나요?",
                "택시메이트의 모든 서비스는 대학교 웹 메일 인증하에 제공됩니다."
                    " 부적절한 사건 발생으로 민/형사상 분쟁이 발생하는 경우, 법적 조치에 필요한 정보 요청에 적극 협조하겠습니다. (탈퇴 후 3개월간 정보 보유)",
              ),
              _QnA(
                "Q. 문의하고 싶은 사항이 있어요.",
                "마이페이지의 \'문의하기\' 버튼을 통해 문의해 주시거나,"
                    "\n99jiasmin@gmail.com로 문의해 주세요.",
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('이걸 발견한 당신! 오늘 행운 가득!!'),
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
                icon: const Icon(Icons.star),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.chevron_left,
          ),
        ),
        Image.asset(
          'asset/imgs/taximate_eng.png',
          width: 120,
        ),
      ],
    );
  }
}
