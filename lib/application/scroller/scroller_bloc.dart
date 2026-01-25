import 'package:bloc/bloc.dart';

import 'scroller_event.dart';
import 'scroller_state.dart';

class ScrollerBloc extends Bloc<ScrollerEvent, ScrollerState> {
  ScrollerBloc() : super(ScrollerState()) {
    on<ScrollerEvent>((event, emit) {});
    on<HideWidgetsRequested>((event, emit) {
      state.copyWith(displayWidget: false);
    });
    on<ShowWidgetsRequested>((event, emit) {
      state.copyWith(displayWidget: true);
    });
  }
}
