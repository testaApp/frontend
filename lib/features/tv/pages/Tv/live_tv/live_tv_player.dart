// video_player_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:blogapp/state/bloc/live-tv-player_bloc-state-event/video_player_bloc.dart';
import 'package:blogapp/state/bloc/live-tv-player_bloc-state-event/video_player_event.dart';
import 'package:blogapp/state/bloc/live-tv-player_bloc-state-event/video_player_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoPlayerBloc()
        ..add(
          InitializePlayer(
            videoUrl,
          ),
        ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
              if (state is VideoPlayerLoading) {
                return _loading();
              }

              if (state is VideoPlayerReady) {
                return _player(state.chewieController);
              }

              if (state is VideoPlayerError) {
                return _error(context);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  bool _isLiveStream(String url) {
    return url.contains('.m3u8') || url.contains('.m3u') || url.contains('.ts');
  }

  Widget _player(ChewieController controller) {
    return Center(
      child: Chewie(controller: controller),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _error(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              DemoLocalizations.networkProblem,
              textAlign: TextAlign.center,
              style: TextUtils.setTextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<VideoPlayerBloc>().add(InitializePlayer(videoUrl));
              },
              label: Text(DemoLocalizations.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
