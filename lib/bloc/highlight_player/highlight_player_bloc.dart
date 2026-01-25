// // BLoC
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import 'highlight_player_event.dart';
// import 'highlight_player_state.dart';

// // BLoC
// class YoutubePlayerBloc extends Bloc<YoutubePlayerEvent, YoutubePlayerState> {
//   YoutubePlayerBloc() : super(YoutubePlayerInitial()) {
//     on<InitializePlayer>((event, emit) {
//       final videoId = YoutubePlayer.convertUrlToId(event.videoUrl);
//       final controller = YoutubePlayerController(
//         initialVideoId: videoId ?? '',
//         flags: const YoutubePlayerFlags(
//           autoPlay: true,
//           mute: false,
//           isLive: false,
//           showLiveFullscreenButton: true,
//         ),
//       );
//       emit(YoutubePlayerReady(controller));
//     });
//   }
// }
