import 'package:equatable/equatable.dart';
import 'package:blogapp/models/HighlighTv_model.dart';
import 'package:blogapp/models/highlight_catagory_model.dart'; // ← Add this import

abstract class HighlightTvState extends Equatable {
  const HighlightTvState();

  @override
  List<Object?> get props => [];
}

class HighlightTvInitial extends HighlightTvState {
  const HighlightTvInitial();
}

class HighlightTvLoading extends HighlightTvState {}

class HighlightTvError extends HighlightTvState {
  final String message;

  const HighlightTvError(this.message); // ← Must be const constructor

  @override
  List<Object?> get props => [message];
}

class HighlightTvLoaded extends HighlightTvState {
  final List<Highlight> recentHighlights;
  final List<Category> categories;
  final Map<String, List<Highlight>> categoryVideos;
  final bool hasMoreCategories;
  final Map<String, bool> hasMoreCategoryVideos;
  final Map<String, int> categoryPages; // ← Add this

  const HighlightTvLoaded({
    required this.recentHighlights,
    required this.categories,
    required this.categoryVideos,
    required this.hasMoreCategories,
    required this.hasMoreCategoryVideos,
    required this.categoryPages, // ← Required
  });

  HighlightTvLoaded copyWith({
    List<Highlight>? recentHighlights,
    List<Category>? categories,
    Map<String, List<Highlight>>? categoryVideos,
    bool? hasMoreCategories,
    Map<String, bool>? hasMoreCategoryVideos,
    Map<String, int>? categoryPages, // ← Allow override
  }) {
    return HighlightTvLoaded(
      recentHighlights: recentHighlights ?? this.recentHighlights,
      categories: categories ?? this.categories,
      categoryVideos: categoryVideos ?? this.categoryVideos,
      hasMoreCategories: hasMoreCategories ?? this.hasMoreCategories,
      hasMoreCategoryVideos:
          hasMoreCategoryVideos ?? this.hasMoreCategoryVideos,
      categoryPages: categoryPages ?? this.categoryPages,
    );
  }

  @override
  List<Object?> get props => [
        recentHighlights,
        categories,
        categoryVideos,
        hasMoreCategories,
        hasMoreCategoryVideos,
        categoryPages,
      ];
}
