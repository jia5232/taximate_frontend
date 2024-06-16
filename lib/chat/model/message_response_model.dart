import 'package:json_annotation/json_annotation.dart';

part 'message_response_model.g.dart';

@JsonSerializable()
class MessageResponseModel {
  final int id;
  final String type;
  final String content;
  final String nickname;
  final DateTime createdTime;

  MessageResponseModel({
    required this.id,
    required this.type,
    required this.content,
    required this.nickname,
    required this.createdTime,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json)
  => _$MessageResponseModelFromJson(json);
}