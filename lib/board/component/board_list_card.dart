import 'package:flutter/material.dart';
import '../../common/const/colors.dart';
import '../model/board_list_model.dart';

class BoardListCard extends StatelessWidget {
  final BoardListModel boardListModel;

  const BoardListCard({
    required this.boardListModel,
    super.key,
  });

  factory BoardListCard.fromModel({required BoardListModel boardListModel}) {
    return BoardListCard(
      boardListModel: boardListModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> departTimeParts = boardListModel.departTime.split("T");
    String datePart = departTimeParts.length > 0 ? departTimeParts[0] : "";
    String timePart = departTimeParts.length > 1 ? departTimeParts[1] : "";

    final discountedPrice = boardListModel.cost ~/ boardListModel.maxMember;

    final costTextStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: PRIMARY_COLOR,
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                boardListModel.depart,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16.0,
                  color: Colors.grey,
                ),
              ),
              Text(
                boardListModel.arrive,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(
                Icons.person,
                color: PRIMARY_COLOR,
                size: 18.0,
              ),
              SizedBox(width: 4.0),
              Text(
                boardListModel.nowMember.toString(),
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            '$datePart일 $timePart분 출발',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                '${boardListModel.maxMember}명 모이면 $discountedPrice원/',
                style: costTextStyle,
              ),
              Text(
                '${boardListModel.cost}',
                style: costTextStyle.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              Text(
                '원',
                style: costTextStyle.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
