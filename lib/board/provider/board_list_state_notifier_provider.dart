import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taximate/board/repository/board_list_repository_provider.dart';
import 'package:taximate/common/model/cursor_pagination_model.dart';

final boardListStateNotifierProvider = StateNotifierProvider<BoardListStateNotifier, CursorPaginationModelBase>(
      (ref) {
    final repository = ref.watch(boardListRepositoryProvider);
    return BoardListStateNotifier(repository: repository);
  },
);

class BoardListStateNotifier extends StateNotifier<CursorPaginationModelBase> {
  BoardListStateNotifier({required this.repository}) : super(CursorPaginationModelLoading()) {
    paginate();
  }

  final BoardListRepository repository;
  bool _fetchingData = false;
  int lastPostId = 0;

  Future<void> paginate({bool fetchMore = false, bool forceRefetch = false}) async {
    if (_fetchingData) return;
    _fetchingData = true;

    try {
      if (state is CursorPaginationModel && !forceRefetch) {
        final pState = state as CursorPaginationModel;
        if (!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading = state is CursorPaginationModelLoading;
      final isRefetching = state is CursorPaginationModelRefetching;
      final isFetchingMore = state is CursorPaginationModelFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      if (fetchMore) {
        final pState = state as CursorPaginationModel;
        state = CursorPaginationModelFetchingMore(meta: pState.meta, data: pState.data);
        lastPostId = pState.data.last.chatRoomId;
      } else {
        if (state is CursorPaginationModel && !forceRefetch) {
          final pState = state as CursorPaginationModel;
          state = CursorPaginationModelRefetching(meta: pState.meta, data: pState.data);
        } else {
          state = CursorPaginationModelLoading();
        }
      }

      final response = await repository.paginate(lastPostId);
      if (!mounted) return;

      if (state is CursorPaginationModelFetchingMore) {
        final pState = state as CursorPaginationModelFetchingMore;
        state = response.copyWith(data: [...pState.data, ...response.data]);
      } else {
        state = response;
      }
    } catch (e) {
      if (!mounted) return;
      state = CursorPaginationModelError(message: 'Failed to fetch data: $e');
    } finally {
      _fetchingData = false;
    }
  }
}
