import 'dart:async';
import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/social_media/social_media_bloc.dart';
import '../../../bloc/social_media/social_media_event.dart';
import '../../../bloc/social_media/social_media_state.dart';
import '../../../localization/demo_localization.dart';
import '../../../models/social_media/social_media_model.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';
import 'telegram.dart';

class Telegram extends StatefulWidget {
  const Telegram({super.key});

  @override
  State<Telegram> createState() => _TelegramPostsState();
}

class _TelegramPostsState extends State<Telegram> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNextPage = false;
  int count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (count == 0) {
      context.read<SocialMediaBloc>().add(TelegramPostsRequested());
      count++;
    }
    _startTimer();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final currentPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100;

    if (shouldLoadNextPage && !isLoadingNextPage) {
      setState(() {
        isLoadingNextPage = true;
      });
      context.read<SocialMediaBloc>().add(LoadNextPageTwitter());

      Future.delayed(Duration.zero, () {
        context.read<SocialMediaBloc>().add(LoadNextPageTwitter());
        setState(() {
          isLoadingNextPage = false;
        });
      });
    }
  }

  Future<void> _refresh() async {
    context.read<SocialMediaBloc>().add(TelegramPostsRequested());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
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
        if (state.telegramRequest == postRequest.requestInProgress) {
          return Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.5,
                    child: Lottie.asset(
                      'assets/telegram.json',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        } else if (state.telegramRequest == postRequest.requestFailure) {
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
        } else if (state.telegramRequest == postRequest.requestSuccess) {
          return Stack(
            children: [
              Positioned(
                top: -200.h,
                bottom: -200.h,
                child: Image.asset(
                  'assets/telegram_bg.jpeg',
                  fit: BoxFit.fitWidth,
                  width: 360.w,
                ),
              ),
              CustomRefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: state.telegramPosts.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 55.h),
                  itemBuilder: (context, idx) {
                    PostModel post = state.telegramPosts[idx];
                    int randomLikes = generateRandomNumber(10000, 100000);
                    int randomComments = generateRandomNumber(10000, 100000);
                    return TelegramWgt(
                      feedText: post.contentText,
                      commentsCount: randomComments,
                      likesCount: randomLikes,
                      userName: post.authors,
                      previewImage: post.previewImage != null
                          ? 'https://${post.previewImage}'
                          : '',
                      author: post.accountName,
                      userImage: '',
                      feedImage: post.image,
                      feedTime: post.datePublished,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
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
                            child: Lottie.asset('assets/telegram.json'),
                          ),
                        ),
                      Transform.translate(
                        offset: Offset(0, 100.0 * controller.value),
                        child: child,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }
        return Container(
          child: Text(
            'unknown state',
            style: TextUtils.setTextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
