import 'package:flutter_riverpod/flutter_riverpod.dart';

final showScrollToBottomButtonProvider = StateProvider<bool>((ref) {
  return false; // 초기값 false로 설정하여 버튼을 숨김!
});