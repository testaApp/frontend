import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/social_media/social_media_bloc.dart';
import '../../../bloc/social_media/social_media_event.dart';
import '../../../bloc/social_media/social_media_state.dart';
import '../../../models/social_media/social_media_model.dart';
import 'instagram.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';
import '../../../localization/demo_localization.dart';

class InstagramPosts extends StatefulWidget {
  const InstagramPosts({super.key});

  @override
  State<InstagramPosts> createState() => _InstagramPostsState();
}

class _InstagramPostsState extends State<InstagramPosts> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    context.read<SocialMediaBloc>().add(InstagramPostsRequested());
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingNextPage) {
      setState(() {
        isLoadingNextPage = true;
      });
      context.read<SocialMediaBloc>().add(LoadNextPageInstagram());
    }
  }

  Future<void> _refresh() async {
    context.read<SocialMediaBloc>().add(InstagramPostsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialMediaBloc, SocialMediaState>(
      builder: (context, state) {
        if (state.instagramRequest == postRequest.requestInProgress) {
          return Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/instagram.json',
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
        } else if (state.instagramRequest == postRequest.requestFailure) {
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
        } else if (state.instagramRequest == postRequest.requestSuccess) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: state.instagramPosts.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, idx) {
                PostModel post = state.instagramPosts[idx];

                return Instagram(
                  feedText: post.contentText,
                  likes: 12,
                  username: post.authors,
                  profilePicture: post.image ?? '',
                  image: post.previewImage ?? '',
                  time: post.datePublished,
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 8,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
