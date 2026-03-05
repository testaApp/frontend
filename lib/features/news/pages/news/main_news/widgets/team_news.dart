import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/state/bloc/news/news_bloc.dart';
import 'package:blogapp/state/bloc/news/news_event.dart';
import 'package:blogapp/state/bloc/news/news_state.dart';
import 'package:blogapp/components/timeFormatter.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/news.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/news/pages/news/main_news/news_detail.dart';

class TeamNewsPage extends StatefulWidget {
  final String teamName;

  const TeamNewsPage({super.key, required this.teamName});

  @override
  State<TeamNewsPage> createState() => _TeamNewsPageState();
}

class _TeamNewsPageState extends State<TeamNewsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _loadingNext = false;

  @override
  void initState() {
    super.initState();
    if (widget.teamName.isNotEmpty) {
      context.read<NewsBloc>().add(
            TeamNewsRequested(
              teamName: widget.teamName,
              language: localLanguageNotifier.value,
            ),
          );
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingNext) {
      _loadingNext = true;
      context.read<NewsBloc>().add(
            TeamNewsNextPageRequested(
              teamName: widget.teamName,
              language: localLanguageNotifier.value,
            ),
          );
      Future.delayed(const Duration(milliseconds: 500))
          .then((_) => _loadingNext = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state.teamNewsStatus == NewsRequest.requestInProgress &&
            state.teamNews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.teamNews.isEmpty) {
          return const Center(child: Text('No news yet'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: state.teamNews.length,
          itemBuilder: (context, index) {
            final News news = state.teamNews[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              title: Text(
                news.summarizedTitle ?? '',
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                formatTimeForNews(news.publishedDate ?? ''),
                style: TextUtils.setTextStyle(fontSize: 11.sp),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailPage(id: news.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
