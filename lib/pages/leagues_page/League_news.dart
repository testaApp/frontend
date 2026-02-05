import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../bloc/news/news_bloc.dart';
import '../../bloc/news/news_event.dart';
import '../../bloc/news/news_state.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import '../appbar_pages/news/main_news/widgets/headline.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';

class LeagueNews extends StatefulWidget {
  final String leagueName;
  const LeagueNews({super.key, required this.leagueName});

  @override
  State<LeagueNews> createState() => _LeagueNewsState();
}

class _LeagueNewsState extends State<LeagueNews> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<NewsBloc>().add(LeagueNewsRequested(
        language: localLanguageNotifier.value, leagueName: widget.leagueName));
  }

  void _scrollListener() {
    final currentPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100;

    if (shouldLoadNextPage) {
      context.read<NewsBloc>().add(LeagueNewsNextPageRequested(
          language: localLanguageNotifier.value, leagueName: widget.leagueName));
    }
  }

  Future<void> _refresh() async {}

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state.leagueNewsStatus == NewsRequest.requestInProgress) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 90.h),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Lottie.asset(
                    'assets/bouncingball.json',
                    height: 190.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          }

          if (state.leagueNewsStatus == NewsRequest.requestFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/404.gif',
                    height: 200.h,
                    fit: BoxFit.fitHeight,
                    color: Colorscontainer.greenColor,
                    width: 300.w,
                  ),
                  Text(
                    DemoLocalizations.networkProblem,
                    style: TextUtils.setTextStyle(
                      color: Colorscontainer.greenColor,
                      fontSize: 15.sp,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NewsBloc>().add(LeagueNewsRequested(
                          language: localLanguageNotifier.value,
                          leagueName: widget.leagueName));
                    },
                    child: Text(DemoLocalizations.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (state.leagueNewsStatus == NewsRequest.requestSuccess) {
            // final isLastPage = state.isLastPage;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.leagueNews.length,
                      padding: EdgeInsets.only(bottom: 35.h),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index + 1 <= state.leagueNews.length) {
                          final news = state.leagueNews[index];
                          return HeadlineWidget(
                            news: news,
                            foryou: true,
                          );
                        }
                        return state.isLastPage
                            ? Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: const CircularProgressIndicator(),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                const Center(
                  child: CircularProgressIndicator(),
                )
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120.h),
              Padding(
                padding: EdgeInsets.fromLTRB(30.w, 0, 0, 0),
                child: Image.asset(
                  'assets/bouncing_ball.gif',
                  height: 130.h,
                  color: Colorscontainer.greenColor,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
