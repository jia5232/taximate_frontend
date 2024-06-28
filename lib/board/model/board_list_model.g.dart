// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardListModel _$BoardListModelFromJson(Map<String, dynamic> json) =>
    BoardListModel(
      isFromSchool: json['isFromSchool'] as bool,
      depart: json['depart'] as String,
      arrive: json['arrive'] as String,
      departTime: json['departTime'] as String,
      cost: (json['cost'] as num).toInt(),
      maxMember: (json['maxMember'] as num).toInt(),
      nowMember: (json['nowMember'] as num).toInt(),
      openChatLink: json['openChatLink'] as String,
      id: (json['id'] as num).toInt(),
      isAuthor: json['isAuthor'] as bool,
      authorName: json['authorName'] as String,
      authorId: (json['authorId'] as num).toInt(),
    );

Map<String, dynamic> _$BoardListModelToJson(BoardListModel instance) =>
    <String, dynamic>{
      'isFromSchool': instance.isFromSchool,
      'depart': instance.depart,
      'arrive': instance.arrive,
      'departTime': instance.departTime,
      'cost': instance.cost,
      'maxMember': instance.maxMember,
      'nowMember': instance.nowMember,
      'openChatLink': instance.openChatLink,
      'id': instance.id,
      'isAuthor': instance.isAuthor,
      'authorName': instance.authorName,
      'authorId': instance.authorId,
    };
