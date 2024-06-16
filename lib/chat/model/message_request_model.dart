import 'package:json_annotation/json_annotation.dart';

part 'message_request_model.g.dart';

@JsonSerializable()
class MessageRequestModel {
  final int chatRoomId;
  final String content;

  MessageRequestModel({required this.chatRoomId, required this.content});

  Map<String, dynamic> toJson() => _$MessageRequestModelToJson(this);
}