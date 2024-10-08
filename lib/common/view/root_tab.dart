import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/board/provider/board_list_state_notifier_provider.dart';

import '../../board/view/board_list_screen.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../../member/view/mypage_screen.dart';
import '../../post/provider/post_state_notifier_provider.dart';
import '../../post/view/post_screen.dart';
import '../const/colors.dart';
import '../layout/default_layout.dart';

class RootTab extends ConsumerStatefulWidget {
  static String get routeName => 'home';
  final int initialIndex;

  const RootTab({
    required this.initialIndex,
    super.key,
  });

  @override
  ConsumerState<RootTab> createState() => _RootTabState();
}

class _RootTabState extends ConsumerState<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
    controller.addListener(tabListener);
    index = widget.initialIndex;
  }

  void tabListener() async {
    setState(() {
      index = controller.index;
    });
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          PostScreen(),
          BoardListScreen(),
          MyPageScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_taxi,
              size: 30.0,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              size: 30.0,
            ),
            label: '모임',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30.0,
            ),
            label: '마이페이지',
          ),
        ],
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
        ),
      ),
    );
  }
}
