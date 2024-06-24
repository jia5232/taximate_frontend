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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      width: MediaQuery.of(context).size.width,
      height: 100.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(boardListModel.depart),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 14.0,
                ),
              ),
              Text(boardListModel.arrive),
              SizedBox(width: 8.0),
              Icon(
                Icons.person,
                color: PRIMARY_COLOR,
                size: 18.0,
              ),
              Text(boardListModel.nowMember.toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${boardListModel.departTime.split(" ")[0]}일 ${boardListModel.departTime.split(" ")[1]} 출발',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          // Add more fields or UI components here if needed
        ],
      ),
    );
  }
}
