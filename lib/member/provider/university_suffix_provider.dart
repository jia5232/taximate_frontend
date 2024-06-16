import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final universitySuffixProvider = FutureProvider<Map<String, String>>((ref) async {
  return await loadUniversityEmailSuffixes();
});

Future<Map<String, String>> loadUniversityEmailSuffixes() async {
  final jsonString = await rootBundle.loadString('asset/jsons/univs_suffix.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  return jsonMap.map((key, value) => MapEntry(key, value.toString()));
}