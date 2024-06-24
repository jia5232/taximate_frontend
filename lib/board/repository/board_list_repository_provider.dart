import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import 'package:riverpod/riverpod.dart';
import 'package:taximate/board/model/board_list_model.dart';

import '../../common/const/data.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/provider/dio_provider.dart';

part 'board_list_repository_provider.g.dart';

final boardListRepositoryProvider = Provider<BoardListRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = BoardListRepository(dio, baseUrl: "http://$ip/posts");
  return repository;
});

@RestApi()
abstract class BoardListRepository {
  factory BoardListRepository(Dio dio, {String baseUrl}) = _BoardListRepository;

  @GET('/joined')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPaginationModel<BoardListModel>> paginate(
      @Query('lastPostId') int lastPostId,
      );
}
