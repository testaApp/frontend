import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/Matches_model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'highlights_page_event.dart';
import 'highlights_page_state.dart';

class HighlightsPageBloc
    extends Bloc<HighlightsPageEvent, HighlightsPageState> {
  HighlightsPageBloc() : super(HighlightsPageState()) {
    on<HighlightsPageEvent>((event, emit) {});
    on<HighlightsRequested>((event, emit) async {
      emit(state.copyWith(status: highlightsPageStatus.requested));

      final response =
          await http.get(Uri.parse('${BaseUrl().url}/api/matches'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<Matches_model> highlights = [];
        for (int i = 0; i < responseData.length; i++) {
          highlights.add(Matches_model.fromJson(responseData[i]));
        }
        emit(state.copyWith(
            status: highlightsPageStatus.requestSuccess,
            highlights: highlights));
      } else if (response.statusCode == 500) {
        emit(state.copyWith(
          status: highlightsPageStatus.serverError,
        ));
      } else {
        emit(state.copyWith(status: highlightsPageStatus.networkFailure));
      }
    });
  }
}
