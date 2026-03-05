import 'package:equatable/equatable.dart';

class VideoPageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class VideosRequested extends VideoPageEvent {
  final String category;

  VideosRequested({required this.category});

  @override
  List<Object> get props => [category];
}
