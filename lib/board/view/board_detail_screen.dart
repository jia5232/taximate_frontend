import 'package:flutter/material.dart';
import 'package:taximate/post/model/post_model.dart';

import '../../common/layout/default_layout.dart';

class BoardDetailScreen extends StatefulWidget {
  static String get routeName => 'boardDetail';
  final PostModel postModel;

  const BoardDetailScreen({
    super.key,
    required this.postModel,
  });

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SingleChildScrollView(
        // SingleChildScrollView -> 화면 크기를 늘려주는것
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // keyboardDismissBehavior = 스크롤을 움직이면 올라왔던 키보드가 바로 다시 내려가게 함..
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Column(
                children: [
                  Text('Depart: ${widget.postModel.depart}'),
                  Text('Arrive: ${widget.postModel.arrive}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
