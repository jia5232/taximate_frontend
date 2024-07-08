import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/common/const/colors.dart';
import '../../../common/component/notice_popup_dialog.dart';
import '../../../common/const/data.dart';
import '../../../common/provider/dio_provider.dart';
import 'email_input_screen.dart';


class SchoolSearchScreen extends ConsumerStatefulWidget {
  @override
  _SchoolSearchScreenState createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends ConsumerState<SchoolSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchedUniversities = [];
  String selectedUniversity = '';
  bool isSearching = false;

  Future<List<String>?> searchUniversities(String searchKeyword) async {
    final dio = ref.watch(dioProvider);

    try {
      final response = await dio.get('$awsIp/universities/search',
          queryParameters: {'searchKeyword': searchKeyword});
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map<String>((univ) => univ as String).toList();
      } else {
        getNoticeDialog(context, '대학교 로드 실패');
      }
    } catch (e) {
      print(e);
      getNoticeDialog(context, '대학교 로드 실패');
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        isSearching = true;
      });

      searchUniversities(_searchController.text).then((results) {
        setState(() {
          searchedUniversities = results ?? [];
          isSearching = false;
        });
      });
    } else {
      setState(() {
        searchedUniversities.clear();
      });
    }
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대학교 검색'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '대학교 이름을 검색해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: PRIMARY_COLOR,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _onSearchChanged,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (selectedUniversity.isNotEmpty)
              Text(
                '선택된 학교: $selectedUniversity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            SizedBox(height: 16),
            if (isSearching)
              CircularProgressIndicator(color: PRIMARY_COLOR)
            else if (searchedUniversities.isEmpty)
              Text('검색 결과가 없습니다.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchedUniversities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(searchedUniversities[index]),
                      onTap: () {
                        setState(() {
                          selectedUniversity = searchedUniversities[index];
                        });
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: selectedUniversity.isNotEmpty
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailInputScreen(
                      university: selectedUniversity,
                    ),
                  ),
                );
              }
                  : null,
              child: Text('다음'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedUniversity.isNotEmpty ? Colors.green : PRIMARY_COLOR,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
