import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final int id;
  final int chatRoomId;
  final bool isFromSchool;
  final String depart;
  final String arrive;
  @JsonKey(
    fromJson: formatLocalDateTime,
    toJson: dateTimeToLocalDateTime,
  )
  final String departTime;
  final int cost;
  final int maxMember;
  final int nowMember;
  final bool isAuthor;

  PostModel({
    required this.id,
    required this.chatRoomId,
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.cost,
    required this.maxMember,
    required this.nowMember,
    required this.isAuthor,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  //json으로 들어온 LocalDatetime 형식을 플러터 앱 내부에서 사용하기 좋은 형태의 스트링으로 변환
  static String formatLocalDateTime(String localDateTimeString) {
    DateTime dateTime = DateTime.parse(localDateTimeString);
    String formattedString = DateFormat('M/d HH:mm').format(dateTime);
    return formattedString;
  }

  //글을 등록할 때 DateTime으로 가져온 날짜를 '2024-01-26T13:17:00.000'형식으로 변환해준다.
  static String dateTimeToLocalDateTime(String formattedDate) {
    // String formattedDate = dateTime.toIso8601String(); -> postFormScreen에서 처리해서 String으로 넘긴다.
    String formattedDateWithoutZ = formattedDate.replaceAll('Z', '');
    return formattedDateWithoutZ; //타임존 설정은 스프링부트 서버에서 하도록 한다.
  }
}
