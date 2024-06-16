import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/chat/model/chat_room_model.dart';
import 'package:taximate/common/provider/dio_provider.dart';
import 'package:retrofit/http.dart';
import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';

part 'chat_room_repository.g.dart';

final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = ChatRoomRepository(dio, baseUrl: "http://$commonServerBaseUrl/chatrooms");
  return repository;
});

@RestApi()
abstract class ChatRoomRepository {
  factory ChatRoomRepository(Dio dio, {String baseUrl}) = _ChatRoomRepository;

  @GET('/my')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPaginationModel<ChatRoomModel>> paginate(
    @Query('lastPostId') int lastPostId,
  );
}
