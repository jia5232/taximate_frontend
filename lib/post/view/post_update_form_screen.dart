import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/common/const/data.dart';
import 'package:taximate/common/layout/default_layout.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/provider/dio_provider.dart';
import '../../member/model/member_model.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../provider/subway_provider.dart';
import '../provider/post_state_notifier_provider.dart';
import '../provider/university_short_name_provider.dart';

class PostUpdateFormScreen extends ConsumerStatefulWidget {
  final int postId;
  final bool isMypageUpdate;

  const PostUpdateFormScreen({
    required this.postId,
    required this.isMypageUpdate,
    super.key,
  });

  @override
  _PostUpdateFormScreenState createState() => _PostUpdateFormScreenState();
}

class _PostUpdateFormScreenState extends ConsumerState<PostUpdateFormScreen> {
  // toggle button을 위한 정보
  bool fromSchool = true; //학교에서 출발
  bool toSchool = false; //학교로 도착
  late List<bool> isSelected;

  // time picker를 위한 정보
  DateTime selectedDateTime = DateTime.now();

  // post 요청에 필요한 정보
  bool isFromSchool = true;
  DateTime departTime = DateTime.now();
  int cost = 0;
  int maxMember = 0;
  int nowMember = 1;

  @override
  void initState() {
    super.initState();
    isSelected = [fromSchool, toSchool];
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.get(
        "http://$apiServerBaseUrl/posts/${widget.postId}",
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      final postData = response.data;
      print(response.data.toString());

      setState(() {
        isFromSchool = postData['isFromSchool'];
        fromSchool = isFromSchool;
        toSchool = !isFromSchool;
        isSelected = [fromSchool, toSchool];

        departTime = DateTime.parse(postData['departTime']);
        selectedDateTime = departTime;

        cost = postData['cost'];
        maxMember = postData['maxMember'];
      });
    } catch (e) {
      getNoticeDialog(context, "오류가 발생했습니다.");
    }
  }

  void toggleSelect(value) {
    if (value == 0) {
      fromSchool = true;
      toSchool = false;
    } else {
      fromSchool = false;
      toSchool = true;
    }
    setState(() {
      isSelected = [fromSchool, toSchool];
      isFromSchool = fromSchool;
    });
  }

  void _showCupertinoDateTimePicker(BuildContext context) {
    final DateTime now = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime:
            selectedDateTime.isBefore(now) ? now : selectedDateTime,
            minimumDate: now, // 최소 시간을 현재 시간으로 설정
            maximumDate: now.add(Duration(days: 1)), // 최대 하루 뒤까지 선택 가능하도록 설정
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                selectedDateTime = newDateTime;
                departTime = newDateTime;
              });
            },
            use24hFormat: true, // 24시간 형식을 사용합니다.
            minuteInterval: 1,
          ),
        );
      },
    );
  }

  void getNoticeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: "닫기",
          onPressed: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void getUpdateResultDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: widget.isMypageUpdate ? "목록으로 돌아가기" : "메인으로 돌아가기",
          onPressed: () async {
            //Dialog를 닫고 메인 페이지로 나가야 하므로 두번 pop.
            Navigator.pop(context);
            Navigator.pop(context);
            if (widget.isMypageUpdate) {
              await ref.read(postStateNotifierProvider.notifier).getMyPosts();
            } else {
              ref.refresh(postStateNotifierProvider);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dio = ref.watch(dioProvider);

    //지하철 정보
    final subwayState = ref.watch(subwayListNotifierProvider);

    String selectedLine = subwayState.selectedLine;
    String selectedStation = subwayState.selectedStation;

    final lineAndStations = subwayState.lineAndStations;

    final nameTextStyle = TextStyle(
      fontSize: 18.0,
    );

    //TextFormField border style!!
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.black,
        width: 1.0,
      ),
    );

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Column(
              children: [
                _buildTop(ref, context),
                SizedBox(height: 10),
                _Notification(),
                SizedBox(height: 20),
                ToggleButtons(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('학교에서 출발'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('학교로 도착'),
                    ),
                  ],
                  isSelected: isSelected,
                  onPressed: toggleSelect,
                  borderColor: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                  borderWidth: 1,
                  selectedBorderColor: Colors.black,
                  fillColor: Colors.transparent,
                  renderBorder: true,
                  constraints: BoxConstraints.expand(
                    width: MediaQuery.of(context).size.width / 2 - 34,
                    height: 40,
                  ),
                  textStyle: TextStyle(fontSize: 18.0),
                  selectedColor: Colors.black,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '도착 / 출발역',
                              style: nameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedLine,
                                  items: lineAndStations.keys
                                      .map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      ))
                                      .toList(),
                                  onChanged: (String? value) {
                                    if (value != null &&
                                        lineAndStations.containsKey(value)) {
                                      setState(() {
                                        selectedLine = value;
                                        selectedStation =
                                        lineAndStations[value]!.isNotEmpty
                                            ? lineAndStations[value]![0]
                                            : null;
                                        ref
                                            .read(subwayListNotifierProvider
                                            .notifier)
                                            .setSelectedLine(value);
                                        if (selectedStation != null) {
                                          ref
                                              .read(subwayListNotifierProvider
                                              .notifier)
                                              .setSelectedStation(
                                              selectedStation!);
                                        }
                                      });
                                    }
                                  },
                                ),
                                DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedStation,
                                  items: lineAndStations[selectedLine]
                                      ?.map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem<String>(
                                        value: e.toString(),
                                        child: Text(e.toString()),
                                      ))
                                      .toList() ??
                                      [],
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedStation = value;
                                        ref
                                            .read(subwayListNotifierProvider
                                            .notifier)
                                            .setSelectedStation(value);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '예상 출발시간',
                              style: nameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: Colors.black),
                                        left: BorderSide(color: Colors.black),
                                        bottom: BorderSide(color: Colors.black),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                      ),
                                    ),
                                    height: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 10, 0, 0),
                                      child: Text(
                                        '${selectedDateTime.month.toString().padLeft(2, '0')}월 ${selectedDateTime.day.toString().padLeft(2, '0')}일 '
                                            '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextButton(
                                    onPressed: () {
                                      _showCupertinoDateTimePicker(context);
                                    },
                                    child: Text('선택'),
                                    style: ButtonStyle(
                                      side: MaterialStateProperty.all(
                                        BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          Colors.grey[200]),
                                      foregroundColor:
                                      MaterialStateProperty.all(
                                          Colors.black),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '예상 출발시간 5분 전까지는 한 장소에 인원을 모으는 것이 좋습니다.',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '예상 소요금액',
                              style: nameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: TextFormField(
                                cursorColor: Colors.black,
                                onChanged: (value) {
                                  cost =
                                  value.isNotEmpty ? int.parse(value) : 0;
                                },
                                keyboardType: TextInputType.number,
                                initialValue: cost.toString(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      '원',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  border: baseBorder,
                                  enabledBorder: baseBorder,
                                  focusedBorder: baseBorder.copyWith(
                                    borderSide: baseBorder.borderSide.copyWith(
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '예상 소요금액은 차량 이용에 필요한 총 비용입니다. (1/N가격 아님)',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '최대 탑승인원',
                              style: nameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: TextFormField(
                                cursorColor: Colors.black,
                                onChanged: (value) {
                                  maxMember =
                                  value.isNotEmpty ? int.parse(value) : 0;
                                },
                                keyboardType: TextInputType.number,
                                initialValue: maxMember.toString(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      '명',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  border: baseBorder,
                                  enabledBorder: baseBorder,
                                  focusedBorder: baseBorder.copyWith(
                                    borderSide: baseBorder.borderSide.copyWith(
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '중형택시 기준 최대 탑승 인원은 운전자 제외 4명입니다. (3명 권장)',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 46,
                        child: TextButton(
                          onPressed: () async {
                            //posts/create으로 요청 보낼때 header에 accessToken 같이 보내야 됨
                            isFromSchool = fromSchool;
                            String? depart = fromSchool
                                ? "" // 백엔드에서 사용자의 대학 이름으로 기재함.
                                : "$selectedStation역";
                            String? arrive =
                            fromSchool ? "$selectedStation역" : "";
                            final formatDepartTime =
                            departTime.toIso8601String();

                            // 예외 처리
                            if (selectedStation == null) {
                              getNoticeDialog(context, "지하철을 선택해주세요.");
                            }
                            if (cost < 4800 || cost > 500000) {
                              getNoticeDialog(context,
                                  "4,800~500,000원 사이\n적절한 금액을 입력해주세요.");
                            }
                            if (maxMember <= 1 || maxMember > 4) {
                              getNoticeDialog(context, "적정 탑승인원은 2~4명 입니다.");
                            }

                            if (selectedStation != null &&
                                cost >= 4800 &&
                                cost <= 500000 &&
                                maxMember > 1 &&
                                maxMember <= 4) {
                              try {
                                final resp = await dio.put(
                                  "http://$apiServerBaseUrl/posts/${widget.postId}",
                                  data: {
                                    'isFromSchool': isFromSchool,
                                    'depart': depart,
                                    'arrive': arrive,
                                    'departTime': formatDepartTime,
                                    'cost': cost,
                                    'maxMember': maxMember,
                                    "nowMember": nowMember,
                                  },
                                  options: Options(
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'accessToken': 'true',
                                    },
                                  ),
                                );
                                if (resp.statusCode == 200) {
                                  getUpdateResultDialog(
                                      context, "글 수정이 완료되었습니다.");
                                }
                              } catch (e) {
                                getNoticeDialog(context, "오류가 발생했습니다.");
                              }
                            }
                          },
                          child: Text(
                            '수정하기',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                              BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                            foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the border radius here
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop(WidgetRef ref, BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);
    String univName = "";

    if (memberState is MemberModel) {
      univName = memberState.univName; // ex.'국민대학교'
    }

    final univShortNameFuture =
    ref.watch(universityShortNameProvider(univName));

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'asset/imgs/taximate_kor.png',
            width: 140,
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 30.0,
            ),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14.0,
    );

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius:
        BorderRadius.all(Radius.circular(12.0)), //Dialog 내부 컨테이너의 border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '방장 안내사항',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. 도착지/출발지 및 관련 정보를 정확히 기재해주세요.',
                style: textStyle,
              ),
              SizedBox(height: 8.0),
              Text(
                '2. 약속 시간 5분 전까지는 모두 정해진 장소로 모여주세요.',
                style: textStyle,
              ),
              SizedBox(height: 8.0),
              Text(
                '3. 택시 호출 및 정산은 만나서 진행해주세요.',
                style: textStyle,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '4. 학교 웹메일 인증하에 운영되므로 부적절한 사건 발생시 민형사상 처벌을 받을 수 있음에 유의바랍니다.',
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
