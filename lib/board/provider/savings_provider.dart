import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../common/const/data.dart';
import '../../common/provider/dio_provider.dart';

final savingsProvider = FutureProvider<int>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    '$awsIp/savings',
    options: Options(
      headers: {
        'accessToken': 'true',
      },
    ),
  );

  if (response.statusCode == 200) {
    return response.data as int;
  } else {
    throw Exception('절약금액 데이터 로드 실패');
  }
});
