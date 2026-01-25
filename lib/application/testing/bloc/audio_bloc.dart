import 'package:bloc/bloc.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  AudioBloc() : super(AudioState()) {
    on<AudioEvent>((event, emit) {});

    on<setStopped>((event, emit) {
      emit(state.copyWith(playing: AudStatus.stopped));
    });
    on<setLivePlaying>((event, emit) {
      emit(state.copyWith(playing: AudStatus.livestream, avatar: event.avatar));
    });

    on<setPlaylistPlaying>((event, emit) {
      emit(state.copyWith(playing: AudStatus.playlist, avatar: event.avatar));
    });
  }
}
