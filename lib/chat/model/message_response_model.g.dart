// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponseModel _$MessageResponseModelFromJson(
        Map<String, dynamic> json) =>
    MessageResponseModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      content: json['content'] as String,
      nickname: json['nickname'] as String,
      createdTime: DateTime.parse(json['createdTime'] as String),
    );

Map<String, dynamic> _$MessageResponseModelToJson(
        MessageResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'content': instance.content,
      'nickname': instance.nickname,
      'createdTime': instance.createdTime.toIso8601String(),
    };
