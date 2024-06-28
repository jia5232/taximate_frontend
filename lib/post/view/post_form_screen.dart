import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/board/provider/board_list_state_notifier_provider.dart';

import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../common/provider/dio_provider.dart';
import '../../member/model/member_model.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../provider/post_state_notifier_provider.dart';

class PostFormScreen extends ConsumerStatefulWidget {
  const PostFormScreen({super.key});

  @override
  _PostFormScreenState createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
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
  int nowMember = 1; //고정
  String? openKakaoLink;

  List<String> _stations = [];
  List<String> _filteredStations = [];
  TextEditingController _searchController = TextEditingController();
  String? _selectedStation; // Initialize as nullable

  @override
  void initState() {
    super.initState();
    isSelected = [fromSchool, toSchool];
    loadStations().then((stations) {
      setState(() {
        _stations = stations;
        _filteredStations = stations;
      });
    });

    _searchController.addListener(() {
      filterStations();
    });
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

  void getPostResultDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: "메인으로 돌아가기",
          onPressed: () {
            //Dialog를 닫고 로그인페이지로 나가야 하므로 두번 pop.
            Navigator.pop(context);
            Navigator.pop(context);
            ref.refresh(postStateNotifierProvider);
            ref.refresh(boardListStateNotifierProvider);
          },
        );
      },
    );
  }

  Future<List<String>> loadStations() async {
    final String response =
    await rootBundle.loadString('asset/jsons/unique_subway_stations.json');
    final data = await json.decode(response);
    return List<String>.from(data.map((station) => station['name']));
  }

  void filterStations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStations = _stations.where((station) {
        return station.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dio = ref.watch(dioProvider);

    final nameTextStyle = TextStyle(
      fontSize: 18.0,
    );

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
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: fromSchool ? '도착역을 검색하세요' : '출발역을 검색하세요',
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
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListView.builder(
                          itemCount: _filteredStations.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                              child: Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white, // ListTile 배경 색상을 흰색으로 설정
                                    borderRadius: BorderRadius.circular(12.0), // 경계 반경을 12로 설정
                                    border: Border.all(
                                      color: Colors.grey.shade200, // 테두리 색상 설정
                                      width: 1.0, // 테두리 두께 설정
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(_filteredStations[index]),
                                    onTap: () {
                                      setState(() {
                                        _selectedStation = _filteredStations[index];
                                      });
                                      print('Selected: $_selectedStation');
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_selectedStation != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: fromSchool
                              ? Text(
                            '도착역: $_selectedStation',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              fontSize: 16.0,
                            ),
                          )
                              : Text(
                            '출발역: $_selectedStation',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              fontSize: 16.0,
                            ),
                          ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '예상 소요금액은 차량 이용에 필요한 총 비용입니다.\n(1/N가격 아님)',
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '중형택시 기준 최대 탑승 인원은 운전자 제외 4명입니다.\n(3명 권장)',
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '오픈카톡 링크',
                              style: nameTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    openKakaoLink = value;
                                  });
                                },
                                cursorColor: Colors.black,
                                maxLines: null, // Allow multiple lines
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  hintText: "오픈 카톡 링크 입력",
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
                                : "$_selectedStation역";
                            String? arrive =
                            fromSchool ? "$_selectedStation역" : "";
                            final formatDepartTime =
                            departTime.toIso8601String();

                            // 예외 처리
                            if (_selectedStation == null) {
                              getNoticeDialog(context, "지하철을 선택해주세요.");
                              return;
                            }
                            if (cost < 4800 || cost > 500000) {
                              getNoticeDialog(context,
                                  "4,800~500,000원 사이\n적절한 금액을 입력해주세요.");
                              return;
                            }
                            if (maxMember <= 1 || maxMember > 4) {
                              getNoticeDialog(context, "적정 탑승인원은 2~4명 입니다.");
                              return;
                            }
                            if (openKakaoLink == null){
                              getNoticeDialog(context, "오픈 카카오톡 단체 채팅 링크를 입력해주세요.");
                              return;
                            }

                            if (_selectedStation != null &&
                                cost >= 4800 &&
                                cost <= 500000 &&
                                maxMember > 1 &&
                                maxMember <= 4) {
                              try {
                                final resp = await dio.post(
                                  "http://$ip/posts/create",
                                  data: {
                                    'isFromSchool': isFromSchool,
                                    'depart': depart,
                                    'arrive': arrive,
                                    'departTime': formatDepartTime,
                                    'cost': cost,
                                    'maxMember': maxMember,
                                    "nowMember": nowMember,
                                    "openChatLink": openKakaoLink,
                                  },
                                  options: Options(
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'accessToken': 'true',
                                    },
                                  ),
                                );
                                if (resp.statusCode == 200) {
                                  //글 작성자는 글을 작성할 때 joinChatRoom() 처리해둔다. -> 백엔드에서 처리함
                                  getPostResultDialog(
                                      context, "글 등록이 완료되었습니다.");
                                }
                              } catch (e) {
                                getNoticeDialog(context, "오류가 발생했습니다.");
                              }
                            }
                          },
                          child: Text(
                            '등록하기',
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
