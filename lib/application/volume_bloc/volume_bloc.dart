import 'package:bloc/bloc.dart';
import 'volume_event.dart';
import 'volume_state.dart';

class VolumeBloc extends Bloc<VolumeEvent, VolumeState> {
  VolumeBloc() : super(VolumeState()) {
    on<VolumeEvent>((event, emit) {});
    on<VolumeChangeRequested>((event, emit) {
      emit(state.copyWith(volume: event.volume));
    });
  }
}
