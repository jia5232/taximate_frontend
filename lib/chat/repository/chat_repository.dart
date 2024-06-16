import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/chat/model/message_response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taximate/common/provider/dio_provider.dart';
import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';

part 'chat_repository.g.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = ChatRepository(dio, baseUrl: "http://$commonServerBaseUrl");
  return repository;
});

@RestApi()
abstract class ChatRepository {
  factory ChatRepository(Dio dio, {String baseUrl}) = _ChatRepository;

  @GET("/history/{chatRoomId}")
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPaginationModel<MessageResponseModel>> getChatHistory({
    @Path() required int chatRoomId,
    @Query("lastMessageId") int? lastMessageId,
    @Query("pageSize") int pageSize = 20,
});
}
