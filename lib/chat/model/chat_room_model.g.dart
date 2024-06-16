// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) =>
    ChatRoomModel(
      chatRoomId: (json['chatRoomId'] as num).toInt(),
      unreadMessageCount: (json['unreadMessageCount'] as num).toInt(),
      depart: json['depart'] as String,
      arrive: json['arrive'] as String,
      departTime:
          ChatRoomModel.formatLocalDateTime(json['departTime'] as String?),
      nowMember: (json['nowMember'] as num).toInt(),
      lastMessageContent: json['lastMessageContent'] as String?,
      messageCreatedTime: ChatRoomModel.formatLocalDateTime(
          json['messageCreatedTime'] as String?),
    );

Map<String, dynamic> _$ChatRoomModelToJson(ChatRoomModel instance) =>
    <String, dynamic>{
      'chatRoomId': instance.chatRoomId,
      'unreadMessageCount': instance.unreadMessageCount,
      'depart': instance.depart,
      'arrive': instance.arrive,
      'departTime': instance.departTime,
      'nowMember': instance.nowMember,
      'lastMessageContent': instance.lastMessageContent,
      'messageCreatedTime': instance.messageCreatedTime,
    };
