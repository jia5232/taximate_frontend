import 'package:flutter/material.dart';
import 'package:taximate/chat/model/chat_room_model.dart';
import 'package:taximate/common/const/colors.dart';

class ChatRoomCard extends StatelessWidget {
  final int chatRoomId;
  final int unreadMessageCount;
  final String depart;
  final String arrive;
  final String departTime;
  final int nowMember;
  final String? lastMessageContent;
  final String? messageCreatedTime;

  const ChatRoomCard({
    required this.chatRoomId,
    required this.unreadMessageCount,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.nowMember,
    this.lastMessageContent,
    this.messageCreatedTime,
    super.key,
  });

  factory ChatRoomCard.fromModel({required ChatRoomModel chatRoomModel}) {
    return ChatRoomCard(
      chatRoomId: chatRoomModel.chatRoomId,
      unreadMessageCount: chatRoomModel.unreadMessageCount,
      depart: chatRoomModel.depart,
      arrive: chatRoomModel.arrive,
      departTime: chatRoomModel.departTime,
      nowMember: chatRoomModel.nowMember,
      lastMessageContent: chatRoomModel.lastMessageContent,
      messageCreatedTime: chatRoomModel.messageCreatedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      width: MediaQuery.of(context).size.width,
      height: 100.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(depart),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 14.0,
                ),
              ),
              Text(arrive),
              SizedBox(width: 8.0),
              Icon(
                Icons.person,
                color: PRIMARY_COLOR,
                size: 18.0,
              ),
              Text(nowMember.toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${departTime.split(" ")[0]}일 ${departTime.split(" ")[1]} 출발',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          if (lastMessageContent != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      lastMessageContent!,
                    ),
                    SizedBox(width: 4.0),
                    if(unreadMessageCount>0)
                      Container(
                        height: 20.0,
                        width: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unreadMessageCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
                Text(
                  messageCreatedTime!,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          if (lastMessageContent == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "",
                ),
              ],
            ),
        ],
      ),
    );
  }
}
