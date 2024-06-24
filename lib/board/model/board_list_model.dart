import 'package:json_annotation/json_annotation.dart';

part 'board_list_model.g.dart';

@JsonSerializable()
class BoardListModel {
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int cost;
  final int maxMember;
  final int nowMember;
  final String openChatLink;
  final int id;
  final bool isAuthor;
  final String authorName;

  BoardListModel({
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.cost,
    required this.maxMember,
    required this.nowMember,
    required this.openChatLink,
    required this.id,
    required this.isAuthor,
    required this.authorName,
  });

  factory BoardListModel.fromJson(Map<String, dynamic> json) => _$BoardListModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardListModelToJson(this);
}
