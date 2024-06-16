import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final universityShortNameProvider = FutureProvider.family<String, String>((ref, univName) async {
  final jsonString = await rootBundle.loadString('asset/jsons/univs_name.json');
  final Map<String, dynamic> univsShortNames = json.decode(jsonString);
  return univsShortNames[univName] ?? 'Unknown';
});
