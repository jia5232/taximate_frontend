import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomIdProvider =
StateProvider<int>((ref) => 1); //채팅방 ID를 관리하는 Provider