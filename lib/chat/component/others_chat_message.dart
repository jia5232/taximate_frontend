import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/const/colors.dart';

class OthersChatMessage extends StatelessWidget {
  final String content;
  final String nickname;
  final DateTime createdTime;

  const OthersChatMessage({
    required this.content,
    required this.nickname,
    required this.createdTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  content,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                // 발품선의 여백 설정
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                // 말풍선의 최소 높이 40, 화면 폭의 60% 사이즈,
                constraints: BoxConstraints(
                  minHeight: 40,
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: PRIMARY_COLOR,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                DateFormat('M/d HH:mm').format(createdTime),
                style: TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
