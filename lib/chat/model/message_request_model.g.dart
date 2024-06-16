// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageRequestModel _$MessageRequestModelFromJson(Map<String, dynamic> json) =>
    MessageRequestModel(
      chatRoomId: (json['chatRoomId'] as num).toInt(),
      content: json['content'] as String,
    );

Map<String, dynamic> _$MessageRequestModelToJson(
        MessageRequestModel instance) =>
    <String, dynamic>{
      'chatRoomId': instance.chatRoomId,
      'content': instance.content,
    };
