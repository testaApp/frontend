import 'dart:async';
import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../bloc/social_media/social_media_bloc.dart';
import '../../../../bloc/social_media/social_media_state.dart';
import '../../../bloc/social_media/social_media_event.dart';
import '../../../localization/demo_localization.dart';
import '../../../models/social_media/social_media_model.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';
import 'twitter.dart';

class TwitterPosts extends StatefulWidget {
  const TwitterPosts({super.key});

  @override
  State<TwitterPosts> createState() => _TwitterPostsState();
}

class _TwitterPostsState extends State<TwitterPosts> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNextPage = false;
  int count = 0;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (count == 0) {
      context.read<SocialMediaBloc>().add(TwitterPostsRequested());
      count++;
    }
    _startTimer();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingNextPage) {
      setState(() {
        isLoadingNextPage = true;
      });
      context.read<SocialMediaBloc>().add(LoadNextPageTwitter());
    }
  }

  Future<void> _refresh() async {
    context.read<SocialMediaBloc>().add(TwitterPostsRequested());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          count++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Random random = Random();

    int generateRandomNumber(int min, int max) {
      return min + random.nextInt(max - min);
    }

    return BlocBuilder<SocialMediaBloc, SocialMediaState>(
      builder: (context, state) {
        if (state.twitterRequest == postRequest.requestInProgress ||
            _isLoading) {
          return Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/x.json',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        }
        if (state.twitterRequest == postRequest.requestFailure) {
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
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: Text(DemoLocalizations.tryAgain),
                ),
              ],
            ),
          );
        }
        return CustomRefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: state.twitterPosts.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, idx) {
              PostModel post = state.twitterPosts[idx];
              int randomLikes = generateRandomNumber(10000, 100000);
              int randomComments = generateRandomNumber(10000, 100000);
              return TwitterWgt(
                feedText: post.contentText,
                commentsCount: randomComments,
                likesCount: randomLikes,
                userName: post.authors,
                author: post.accountName,
                userImage: post.profile_pic ?? '',
                feedImage: post.image,
                feedTime: post.datePublished,
                textColor: Theme.of(context)
                    .colorScheme
                    .onSurface, // Use onSurface color
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(height: 1, color: Colors.grey.shade600),
            ),
          ),
          builder: (context, child, controller) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                if (!controller.isIdle)
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Lottie.asset('assets/x.json'),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, 100.0 * controller.value),
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
