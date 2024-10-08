import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/common/dio/dio_custom_interceptor.dart';
import 'package:taximate/common/dio/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  //provider 안에서 다른 provider를 참조할때는 watch를 사용하는 것이 좋다.
  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage, ref, dio),
  );

  return dio;
});
