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
import 'facebook.dart';

class FacebookPosts extends StatefulWidget {
  const FacebookPosts({super.key});

  @override
  State<FacebookPosts> createState() => _FacebookPostsState();
}

class _FacebookPostsState extends State<FacebookPosts> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    context.read<SocialMediaBloc>().add(FacebookPostsRequested());
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingNextPage) {
      setState(() {
        isLoadingNextPage = true;
      });
      context.read<SocialMediaBloc>().add(LoadNextPageFacebook());
    }
  }

  Future<void> _refresh() async {
    context.read<SocialMediaBloc>().add(FacebookPostsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialMediaBloc, SocialMediaState>(
      builder: (context, state) {
        if (state.facebookRequest == postRequest.requestInProgress) {
          return Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/facebook_icon.json',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          );
        } else if (state.facebookRequest == postRequest.requestFailure) {
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

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: state.facebookPosts.length,
            padding: EdgeInsets.only(bottom: 55.h),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, idx) {
              PostModel post = state.facebookPosts[idx];
              return FacebookWgt(
                  feedText: post.contentText,
                  commentsCount: 12,
                  likesCount: 55,
                  userName: post.authors,
                  userImage: post.previewImage ?? '',
                  feedImage: post.image,
                  feedTime: post.datePublished);
            },
            separatorBuilder: (context, index) => const Divider(
              height: 4,
            ),
          ),
        );
      },
    );
  }
}
