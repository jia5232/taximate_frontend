import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../common/const/data.dart';
import '../../common/dio/secure_storage.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../model/message_request_model.dart';
import '../model/message_response_model.dart';
import 'dart:convert';

import 'chat_history_provider.dart';


final webSocketStateProvider = StateNotifierProvider<WebSocketStateNotifier, WebSocketState>(
      (ref) => WebSocketStateNotifier(ref: ref),
);

enum WebSocketState {
  connecting,
  connected,
  disconnected,
  failed,
}

class WebSocketStateNotifier extends StateNotifier<WebSocketState> {
  StompClient? stompClient;
  final Ref ref;
  Function? unsubscribeFn; // 구독 해제 함수를 저장하는 변수
  Set<String> receivedMessageIds = Set(); // 수신된 메시지 ID를 저장

  // 메시지 수신 시 실행할 콜백 함수
  void Function(MessageResponseModel message)? onMessageReceivedCallback;

  WebSocketStateNotifier({required this.ref}) : super(WebSocketState.disconnected);

  void connect(String accessToken, int chatRoomId) {
    if (state == WebSocketState.connecting || state == WebSocketState.connected) {
      return;
    }
    state = WebSocketState.connecting;

    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$commonServerBaseUrl/ws-stomp',
        onConnect: (StompFrame frame) {
          state = WebSocketState.connected;
          subscribeToChatRoom(chatRoomId);
        },
        beforeConnect: () async {
          await Future.delayed(Duration(seconds: 1));
        },
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        onWebSocketError: (dynamic error) {
          print(error.toString());
          if (error.toString().contains("토큰이 만료되었습니다.")) {
            refreshTokenAndReconnect(chatRoomId);
          } else {
            state = WebSocketState.failed;
          }
        },
      ),
    );

    stompClient?.activate();
  }

  void setOnMessageReceivedCallback(void Function(MessageResponseModel message) callback) {
    onMessageReceivedCallback = callback;
  }

  void subscribeToChatRoom(int chatRoomId) {
    unsubscribeFn = stompClient?.subscribe(
      destination: '/sub/chatroom/$chatRoomId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> messageJson = jsonDecode(frame.body!);
          final MessageResponseModel message = MessageResponseModel.fromJson(messageJson);

          if (!receivedMessageIds.contains(message.id.toString())) {
            receivedMessageIds.add(message.id.toString()); // 메시지 ID 저장
            if (onMessageReceivedCallback != null) {
              onMessageReceivedCallback!(message); // 설정된 콜백 함수 호출
            }
            ref.read(chatHistoryProvider.notifier).addNewMessage(message);
          } else {
            print("중복된 메시지 -> 상태관리 추가 x: ${message.id}");
          }
        }
      },
    );
  }

  void sendMessage(int chatRoomId, String content) {
    if (state != WebSocketState.connected) {
      print("WebSocket is not connected.");
      return;
    }

    final messageRequestModel = MessageRequestModel(
      chatRoomId: chatRoomId,
      content: content,
    );

    final messageJson = jsonEncode(messageRequestModel.toJson());
    print("Sending message: $messageJson");

    stompClient?.send(
      destination: '/pub/chat/message',
      body: messageJson,
    );
  }

  Future<void> refreshTokenAndReconnect(int chatRoomId) async {
    // 최대 재시도 횟수 정의!!
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final dio = Dio();
        final refreshToken = await ref.read(secureStorageProvider).read(key: REFRESH_TOKEN_KEY);
        final response = await dio.post(
          'http://$apiServerBaseUrl/token',
          options: Options(
            headers: {'Authorization': 'Bearer $refreshToken'},
          ),
        );

        final newRefreshToken = response.data['refreshToken'] != null
            ? response.data['refreshToken']!.substring("Bearer ".length)
            : null;

        final newAccessToken = response.data['accessToken'] != null
            ? response.data['accessToken']!.substring("Bearer ".length)
            : null;

        if (newAccessToken != null && newRefreshToken != null) {
          await ref.read(secureStorageProvider).write(key: ACCESS_TOKEN_KEY, value: newAccessToken);
          await ref.read(secureStorageProvider).write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);
          connect(newAccessToken, chatRoomId); // 갱신된 토큰으로 연결 시도
          return;
        } else {
          throw Exception('Token refresh failed');
        }
      } catch (e) {
        retryCount++;
        print('Token refresh failed, retrying... ($retryCount/$maxRetries)');
        await Future.delayed(Duration(seconds: 2)); // 재시도 전 딜레이
      }
    }

    // 모든 재시도가 실패한 경우 사용자 로그아웃 처리한다..
    print('Token refresh failed...');
    ref.read(memberStateNotifierProvider.notifier).logout();
  }

  void disconnect() {
    if (state != WebSocketState.connected) {
      return;
    }
    if (unsubscribeFn != null) {
      unsubscribeFn!();
    }
    stompClient?.deactivate();
    state = WebSocketState.disconnected;
  }
}


