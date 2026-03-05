import 'package:flutter_bloc/flutter_bloc.dart';

import 'persistent_player_event.dart';
import 'persistent_player_state.dart';

class PersistentPlayerBloc
    extends Bloc<PersistentPlayerEvent, PersistentPlayerState> {
  PersistentPlayerBloc() : super(PersistentPlayerState()) {
    on<ShowPersistentPlayer>((event, emit) {
      emit(state.copyWith(
        status: PersistentPlayerStatus.visible,
        avatar: event.avatar,
        name: event.name,
        station: event.station,
        program: event.program,
        liveLink: event.liveLink,
      ));
    });

    on<HidePersistentPlayer>((event, emit) {
      emit(state.copyWith(status: PersistentPlayerStatus.hidden));
    });
  }
}
