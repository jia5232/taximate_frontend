import 'package:flutter_riverpod/flutter_riverpod.dart';

// postScreen에 필요한 data들을 관리하는 provider들

final fromSchoolProvider = StateProvider<bool>((ref) => true);

final searchKeywordProvider = StateProvider<String?>((ref) => '');