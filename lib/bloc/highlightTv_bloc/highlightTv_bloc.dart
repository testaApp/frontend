import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/HighlighTv_model.dart';
import '../../models/highlight_catagory_model.dart';
import '../../util/baseUrl.dart';
import 'highlightTv_Event.dart';
import 'highlightTv_State.dart';

class HighlightTvBloc extends Bloc<HighlightTvEvent, HighlightTvState> {
  int currentCategoryPage = 0;

  HighlightTvBloc() : super(const HighlightTvInitial()) {
    on<FetchRecentHighlights>(_onFetchRecentHighlights);
    on<FetchCategories>(_onFetchCategories);
    on<RefreshHighlightTv>(_onRefreshHighlightTv);
    on<FetchCategoryVideos>(_onFetchCategoryVideos);
  }

  Future<void> _onFetchRecentHighlights(
    FetchRecentHighlights event,
    Emitter<HighlightTvState> emit,
  ) async {
    try {
      final response =
          await http.get(Uri.parse('${BaseUrl().url}/recent-highlights'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final List<dynamic> jsonList = jsonMap['highlights'] ?? [];
        final List<Highlight> highlights =
            jsonList.map((json) => Highlight.fromJson(json)).toList();

        if (state is HighlightTvLoaded) {
          emit((state as HighlightTvLoaded).copyWith(
            recentHighlights: highlights,
          ));
        } else {
          emit(HighlightTvLoaded(
            recentHighlights: highlights,
            categories: const [],
            categoryVideos: const {},
            hasMoreCategories: true,
            hasMoreCategoryVideos: const {},
            categoryPages: const {},
          ));
        }
      } else {
        emit(const HighlightTvError('Failed to load recent highlights'));
      }
    } catch (e) {
      emit(HighlightTvError('Error fetching recent highlights: $e'));
    }
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<HighlightTvState> emit,
  ) async {
    final bool isRefresh = event.page == 1;

    if (!isRefresh &&
        state is HighlightTvLoaded &&
        !(state as HighlightTvLoaded).hasMoreCategories) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${BaseUrl().url}/highlight-videos/categories?page=${event.page}&limit=10'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonCategories = data['categories'] ?? [];
        final List<Category> newCategories =
            jsonCategories.map((json) => Category.fromJson(json)).toList();
        final bool hasMore = data['hasMore'] ?? false;

        final currentState = state as HighlightTvLoaded?;

        List<Category> updatedCategories = [];
        if (currentState != null && !isRefresh) {
          updatedCategories = [...currentState.categories, ...newCategories];
        } else {
          updatedCategories = newCategories;
        }

        final Map<String, int> preservedPages =
            isRefresh ? {} : (currentState?.categoryPages ?? {});

        emit(HighlightTvLoaded(
          recentHighlights: currentState?.recentHighlights ?? const [],
          categories: updatedCategories,
          categoryVideos: currentState?.categoryVideos ?? {},
          hasMoreCategories: hasMore,
          hasMoreCategoryVideos: currentState?.hasMoreCategoryVideos ?? {},
          categoryPages: preservedPages,
        ));

        for (final category in newCategories) {
          final String categoryName = category.name;
          final bool shouldLoad = isRefresh ||
              currentState == null ||
              !currentState.categories.any((c) => c.name == categoryName);

          if (shouldLoad) {
            add(FetchCategoryVideos(categoryName, 1));
          }
        }

        currentCategoryPage = event.page;
      } else {
        emit(const HighlightTvError('Failed to load categories'));
      }
    } catch (e) {
      emit(HighlightTvError('Error fetching categories: $e'));
    }
  }

  Future<void> _onRefreshHighlightTv(
    RefreshHighlightTv event,
    Emitter<HighlightTvState> emit,
  ) async {
    currentCategoryPage = 0;
    emit(const HighlightTvInitial());
    add(FetchRecentHighlights());
    add(const FetchCategories(1));
  }

  Future<void> _onFetchCategoryVideos(
    FetchCategoryVideos event,
    Emitter<HighlightTvState> emit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${BaseUrl().url}/highlight-videos/category/${Uri.encodeComponent(event.categoryName)}?page=${event.page}&limit=10',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonVideos = data['videos'] ?? [];
        final List<Highlight> videos =
            jsonVideos.map((json) => Highlight.fromJson(json)).toList();
        final bool hasMore = data['hasMore'] ?? false;

        if (state is HighlightTvLoaded) {
          final current = state as HighlightTvLoaded;

          final updatedVideos =
              Map<String, List<Highlight>>.from(current.categoryVideos);
          final updatedHasMore =
              Map<String, bool>.from(current.hasMoreCategoryVideos);
          final updatedPages = Map<String, int>.from(current.categoryPages);

          if (event.page == 1) {
            updatedVideos[event.categoryName] = videos;
          } else {
            updatedVideos[event.categoryName] = [
              ...?updatedVideos[event.categoryName],
              ...videos,
            ];
          }
          updatedHasMore[event.categoryName] = hasMore;
          updatedPages[event.categoryName] = event.page;

          emit(current.copyWith(
            categoryVideos: updatedVideos,
            hasMoreCategoryVideos: updatedHasMore,
            categoryPages: updatedPages,
          ));
        }
      } else if (response.statusCode == 404) {
        emit(const HighlightTvError('League not found'));
      } else {
        emit(HighlightTvError(
            'Failed to load videos for ${event.categoryName}'));
      }
    } catch (e) {
      emit(HighlightTvError('Error fetching videos: $e'));
    }
  }
}
