
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/news/news_bloc.dart';
import '../../../../../bloc/news/news_event.dart';
import '../../../../../bloc/news/news_state.dart';
import '../../../../../components/timeFormatter.dart';
import '../../../../../main.dart';
import '../../../../../models/news.dart';
import '../../../../constants/text_utils.dart';
import '../news_detail.dart';

class PlayerNewsPage extends StatefulWidget {
  final String playerName;

  const PlayerNewsPage({super.key, required this.playerName});

  @override
  State<PlayerNewsPage> createState() => _PlayerNewsPageState();
}

class _PlayerNewsPageState extends State<PlayerNewsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _loadingNext = false;

  @override
  void initState() {
    super.initState();
    if (widget.playerName.isNotEmpty) {
      context.read<NewsBloc>().add(
            PlayerNewsRequested(
              playerName: widget.playerName,
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
            PlayerNewsNextPageRequested(
              playerName: widget.playerName,
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
        if (state.playerNewsStatus == NewsRequest.requestInProgress &&
            state.playerNews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.playerNews.isEmpty) {
          return const Center(child: Text('No news yet'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: state.playerNews.length,
          itemBuilder: (context, index) {
            final News news = state.playerNews[index];
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
