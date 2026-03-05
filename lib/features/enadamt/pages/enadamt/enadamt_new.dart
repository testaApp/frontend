import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:blogapp/state/application/enadamt/podcast/podcast_state.dart';
import 'package:blogapp/state/application/enadamt/podcast/podcast_bloc.dart';
import 'package:blogapp/state/application/enadamt/podcast/podcast_event.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/program_card/PodcastModel.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/enadamt/pages/enadamt/podcast_card.dart';
import 'package:blogapp/features/enadamt/pages/enadamt/program_detail_page.dart';

class EnadamtNew extends StatefulWidget {
  const EnadamtNew({super.key});

  @override
  State<EnadamtNew> createState() => _EnadamtNewState();
}

class _EnadamtNewState extends State<EnadamtNew>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Timer? _periodicTimer;
  bool _isPageActive = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadInitialContent();

    // Add periodic refresh every 10 minutes
    _periodicTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (mounted && _isPageActive) {
        _handleSoftRefresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isPageActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleUserRefresh() async {
    try {
      context.read<PodcastsBloc>().add(PodcastsRefresh());
      // Add a reasonable timeout
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Error during refresh: $e');
    }
  }

  Future<void> _handleSoftRefresh() async {
    try {
      context.read<PodcastsBloc>().add(PodcastsRequested());
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Error during refresh: $e');
    }
  }

  void _loadInitialContent() {
    if (!mounted) return;
    context.read<PodcastsBloc>().add(PodcastsRequested());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<PodcastsBloc>().add(PodcastsLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _handleUserRefresh,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 1),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  DemoLocalizations.listenToYourFavouriteSportProgram,
                  style: TextUtils.setTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PodcastsBloc, PodcastsState>(
                builder: (context, state) {
                  if (state.status == podcastStatus.requestSuccess &&
                      state.podcasts.isNotEmpty) {
                    List<PodcastModel> podcasts =
                        List<PodcastModel>.from(state.podcasts);
                    podcasts.sort((a, b) {
                      if (a.isLive && !b.isLive) return -1;
                      if (!a.isLive && b.isLive) return 1;
                      return 0;
                    });
                    final rowCount = (podcasts.length / 2).ceil();
                    final showLoader = state.isLoadingMore;
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: rowCount + (showLoader ? 1 : 0),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (showLoader && index == rowCount) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildPodcastCard(
                                      podcasts[index * 2])),
                              SizedBox(width: 8.w),
                              if (index * 2 + 1 < podcasts.length)
                                Expanded(
                                    child: _buildPodcastCard(
                                        podcasts[index * 2 + 1])),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state.status == podcastStatus.requestFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/404.gif',
                            width: 200,
                            height: 200,
                            fit: BoxFit.fitHeight,
                            color: Colorscontainer.greenColor,
                          ),
                          Text(
                            DemoLocalizations.networkProblem,
                            style: TextUtils.setTextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<PodcastsBloc>()
                                  .add(PodcastsRequested());
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colorscontainer.greenColor),
                            ),
                            child: Text(
                              DemoLocalizations.tryAgain,
                              style: TextUtils.setTextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Lottie.asset(
                        'assets/podcast.json',
                        height: 250.0,
                        width: 200.0,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastCard(PodcastModel podcast) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Program(
              id: podcast.id,
              avatar: podcast.avatar,
              name: podcast.name,
              program: podcast.program,
              rssLink: podcast.rssLink,
              description: podcast.description,
              time: const [],
              liveLink: podcast.liveLink,
              station: podcast.station,
              isProgram: podcast.isLive,
              programId: podcast.programId, // PASS THE PROGRAM
            ),
          ),
        );
      },
      child: PodcastCard(
        liveLink: podcast.liveLink,
        name: podcast.name,
        station: podcast.station,
        avatar: podcast.avatar,
        program: podcast.program,
        isLive: podcast.isLive,
        rssLink: podcast.rssLink,
        description: podcast.description,
        id: podcast.id,
        programId: podcast.programId, // PASS THE PROGRAM

      ),
    );
  }
}
