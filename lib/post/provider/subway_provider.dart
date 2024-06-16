import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// 2. StateNotifierProvider를 사용하여 SubwayState를 관리하는 SubwayListNotifier
final subwayListNotifierProvider = StateNotifierProvider<SubwayListNotifier, SubwayState>((ref) {

  // FutureProvider에서 로드된 초기 상태를 사용하여 StateNotifier를 생성
  final initialState = ref.watch(subwayStateProvider).asData?.value ?? SubwayState(lineAndStations: {}, selectedLine: '', selectedStation: '');

  return SubwayListNotifier(initialState);
});

class SubwayListNotifier extends StateNotifier<SubwayState> {
  SubwayListNotifier(SubwayState state) : super(state);

  // 선택된 라인이나 역을 변경하는 메서드
  void setSelectedLine(String line) {
    state = state.copyWith(selectedLine: line);
  }

  void setSelectedStation(String station) {
    state = state.copyWith(selectedStation: station);
  }
}

// 1. FutureProvider를 사용하여 SubwayState를 로드하는 함수

final subwayStateProvider = FutureProvider<SubwayState>((ref) async {
  String jsonString = await rootBundle.loadString('asset/jsons/subway_stations.json');
  Map<String, dynamic> lineAndStations = json.decode(jsonString);

  // 초기 선택된 라인과 역을 설정
  String selectedLine = lineAndStations.keys.first;
  String selectedStation = lineAndStations[selectedLine][0];

  return SubwayState(lineAndStations: lineAndStations, selectedLine: selectedLine, selectedStation: selectedStation);
});

class SubwayState {
  final Map<String, dynamic> lineAndStations;
  String selectedLine;
  String selectedStation;

  SubwayState({required this.lineAndStations, required this.selectedLine, required this.selectedStation});

  SubwayState copyWith({
    Map<String, dynamic>? lineAndStations,
    String? selectedLine,
    String? selectedStation,
  }) {
    return SubwayState(
      lineAndStations: lineAndStations ?? this.lineAndStations,
      selectedLine: selectedLine ?? this.selectedLine,
      selectedStation: selectedStation ?? this.selectedStation,
    );
  }
}