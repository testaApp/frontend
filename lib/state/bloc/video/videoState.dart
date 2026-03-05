import 'package:equatable/equatable.dart';

import '../../../../models/video.dart';

enum videoStatus {
  requested,
  serverError,
  requestSuccess,
  networkFailure,
  initial
}

class VideosState extends Equatable {
  final videoStatus status;
  final List<VideosModel> highlights;

  const VideosState({required this.status, required this.highlights});

  factory VideosState.initial() {
    return const VideosState(status: videoStatus.initial, highlights: []);
  }

  VideosState copyWith({videoStatus? status, List<VideosModel>? highlights}) {
    return VideosState(
        status: status ?? this.status,
        highlights: highlights ?? this.highlights);
  }

  @override
  List<Object> get props => [status, highlights];
}
