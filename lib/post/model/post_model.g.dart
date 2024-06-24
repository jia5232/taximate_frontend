// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: (json['id'] as num).toInt(),
      isFromSchool: json['isFromSchool'] as bool,
      depart: json['depart'] as String,
      arrive: json['arrive'] as String,
      departTime: PostModel.formatLocalDateTime(json['departTime'] as String),
      cost: (json['cost'] as num).toInt(),
      maxMember: (json['maxMember'] as num).toInt(),
      nowMember: (json['nowMember'] as num).toInt(),
      isAuthor: json['isAuthor'] as bool,
      openChatLink: json['openChatLink'] as String,
      authorName: json['authorName'] as String,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'isFromSchool': instance.isFromSchool,
      'depart': instance.depart,
      'arrive': instance.arrive,
      'departTime': PostModel.dateTimeToLocalDateTime(instance.departTime),
      'cost': instance.cost,
      'maxMember': instance.maxMember,
      'nowMember': instance.nowMember,
      'isAuthor': instance.isAuthor,
      'openChatLink': instance.openChatLink,
      'authorName': instance.authorName,
    };
