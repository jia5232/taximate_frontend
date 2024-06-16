import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel {
  final int chatRoomId;
  final int unreadMessageCount;
  final String depart;
  final String arrive;
  @JsonKey(
    fromJson: formatLocalDateTime,
  )
  final String departTime;
  final int nowMember;
  final String? lastMessageContent;
  @JsonKey(
    fromJson: formatLocalDateTime,
  )
  final String? messageCreatedTime;

  ChatRoomModel({
    required this.chatRoomId,
    required this.unreadMessageCount,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.nowMember,
    this.lastMessageContent,
    this.messageCreatedTime,
});

  factory ChatRoomModel.fromJson(Map<String, dynamic> json)
  => _$ChatRoomModelFromJson(json);

  //json으로 들어온 LocalDatetime 형식을 플러터 앱 내부에서 사용하기 좋은 형태의 스트링으로 변환
  static String formatLocalDateTime(String? localDateTimeString) {
    if (localDateTimeString == null) return "";
    DateTime dateTime = DateTime.parse(localDateTimeString);
    String formattedString = DateFormat('M/d HH:mm').format(dateTime);
    return formattedString;
  }

  static String safeString(dynamic value) => value?.toString() ?? '';
}