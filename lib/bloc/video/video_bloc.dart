import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../models/video.dart';
import '../../../../util/baseUrl.dart';
import 'videoEvent.dart';
import 'videoState.dart';

class VideoBloc extends Bloc<VideoPageEvent, VideosState> {
  VideoBloc() : super(VideosState.initial()) {
    on<VideosRequested>(_onVideosRequested);
  }

  Future<void> _onVideosRequested(
      VideosRequested event, Emitter<VideosState> emit) async {
    emit(state.copyWith(status: videoStatus.requested));

    final response = await http.get(Uri.parse('${BaseUrl().url}/api/videos'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      List<VideosModel> highlights = [];
      //  responseData.map((highlight)=> HighlightsModel.fromJson(json) ).toList;
      for (int i = 0; i < responseData.length; i++) {
        highlights.add(VideosModel.fromJson(responseData[i]));
      }
      emit(state.copyWith(
          status: videoStatus.requestSuccess, highlights: highlights));
    } else if (response.statusCode == 500) {
      emit(state.copyWith(
        status: videoStatus.serverError,
      ));
    } else {
      emit(state.copyWith(status: videoStatus.networkFailure));
    }
  }
}
