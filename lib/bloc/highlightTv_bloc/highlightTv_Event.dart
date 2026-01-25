import 'package:equatable/equatable.dart';

abstract class HighlightTvEvent extends Equatable {
  const HighlightTvEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecentHighlights extends HighlightTvEvent {}

class FetchCategories extends HighlightTvEvent {
  final int page;

  const FetchCategories(this.page);

  @override
  List<Object?> get props => [page];
}

class FetchCategoryVideos extends HighlightTvEvent {
  final String categoryName; // Name of the league
  final int page;

  const FetchCategoryVideos(this.categoryName, this.page);

  @override
  List<Object?> get props => [categoryName, page];
}

class RefreshHighlightTv extends HighlightTvEvent {
  const RefreshHighlightTv();

  @override
  List<Object?> get props => [];
}
