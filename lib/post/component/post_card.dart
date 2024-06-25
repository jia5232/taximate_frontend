import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taximate/post/model/post_model.dart';

class PostCard extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int maxMember;
  final int nowMember;
  final bool isAuthor;
  final String authorName;

  const PostCard({
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.maxMember,
    required this.nowMember,
    required this.isAuthor,
    required this.authorName,
    super.key,
  });

  factory PostCard.fromModel({required PostModel postModel}) {
    return PostCard(
      isFromSchool: postModel.isFromSchool,
      depart: postModel.depart,
      arrive: postModel.arrive,
      departTime: postModel.departTime,
      maxMember: postModel.maxMember,
      nowMember: postModel.nowMember,
      isAuthor: postModel.isAuthor,
      authorName: postModel.authorName,
    );
  }

  String _getFormattedDate(String departTime) {
    final now = DateTime.now().toUtc().add(Duration(hours: 9));
    final DateFormat fullFormatter = DateFormat('yyyy/M/d H:m');
    final DateFormat dateFormatter = DateFormat('M/d');
    final parsedDate = fullFormatter.parse('2024/$departTime');

    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(Duration(days: 1));

    if (parsedDate.isAfter(startOfToday) &&
        parsedDate.isBefore(startOfTomorrow)) {
      return '오늘';
    } else if (parsedDate.isAfter(startOfTomorrow) &&
        parsedDate.isBefore(startOfTomorrow.add(Duration(days: 1)))) {
      return '내일';
    } else {
      return '${dateFormatter.format(parsedDate)}일';
    }
  }

  @override
  Widget build(BuildContext context) {
    final departTimeList = departTime.split(' ');
    final formattedDate = _getFormattedDate(departTime);

    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 4,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MainText(
                  isFromSchool: isFromSchool,
                  depart: depart,
                  arrive: arrive,
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  '$formattedDate ${departTimeList[1]} 출발',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('방장: $authorName'),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  '현재인원 $nowMember/$maxMember',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainText extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;

  const _MainText(
      {required this.isFromSchool,
      required this.depart,
      required this.arrive,
      super.key});

  @override
  Widget build(BuildContext context) {
    if (isFromSchool) //학교에서 출발
      return Text(
        '$arrive 도착',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
        ),
      );
    else //학교로 도착
      return Text(
        '$depart 출발',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
        ),
      );
  }
}
