import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../bloc/news/news_bloc.dart';
import '../../../../../bloc/news/news_event.dart';
import '../../../../../bloc/news/news_state.dart';
import '../../../../../components/timeFormatter.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../main.dart';
import '../../../../../models/news.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';
import '../../main_news/news_detail.dart';
import 'transfer/Transfertab.dart';
import 'transfer/transfer_bloc.dart';
import 'transfer/transfer_event.dart';
import 'transfer/transfer_model.dart';
import 'transfer/transfer_state.dart';

class TransferPage extends StatefulWidget {
  final Function(double) onScroll;
  const TransferPage({super.key, required this.onScroll});

  @override
  _TransferListState createState() => _TransferListState();
}

class _TransferListState extends State<TransferPage> {
  final ScrollController _scrollController = ScrollController();

  bool isSubmitting = false;
  bool isLoadingNextPage = false;
  final bool _isUpperListScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    context.read<TransferBloc>().add(TransferRequested());
    context
        .read<NewsBloc>()
        .add(TransferNewsRequested(language: localLanguageNotifier.value));
  }

  void _scrollListener() {
    if (_isUpperListScrolling) return;

    final offset = _scrollController.offset;
    widget.onScroll(offset);

    final currentPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100;

    if (shouldLoadNextPage) {
      context.read<NewsBloc>().add(
          TransferLoadnextNewsRequested(language: DemoLocalizations.language));
    } else if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !isLoadingNextPage) {
      setState(() {
        isLoadingNextPage = true;
      });

      context.read<NewsBloc>().add(
          TransferLoadnextNewsRequested(language: localLanguageNotifier.value));

      Future.delayed(const Duration(seconds: 0), () {
        context.read<NewsBloc>().add(TransferLoadnextNewsRequested(
            language: localLanguageNotifier.value));
        setState(() {
          isLoadingNextPage = false;
        });
      });
    }
  }

  Future<void> _refresh() async {
    context
        .read<NewsBloc>()
        .add(TransferNewsRequested(language: localLanguageNotifier.value));
  }

  bool isFullyLoaded(TransferBloc transferBloc, NewsBloc newsBloc) {
    final transferState = transferBloc.state;
    final newsState = newsBloc.state;

    return transferState.status == Transferstatus.requestSuccess &&
        (newsState.transfernewsStatus == NewsRequest.requestSuccess ||
            newsState.transfernews.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DemoLocalizations.transfer_window,
          style: TextUtils.setTextStyle(
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TransferBloc, TransferState>(
        builder: (context, transferState) {
          return BlocBuilder<NewsBloc, NewsState>(
            builder: (context, newsState) {
              if (!isFullyLoaded(
                  context.read<TransferBloc>(), context.read<NewsBloc>())) {
                return Center(
                  child: Lottie.asset(
                    'assets/transfer.json',
                    fit: BoxFit.contain,
                    width: 100,
                    height: 100,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.colorFilter(
                          const ['**'],
                          value: ColorFilter.mode(
                            Colorscontainer.greenColor,
                            BlendMode.srcATop,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  controller: _scrollController,
                  children: [
                    if (transferState.status == Transferstatus.requestSuccess)
                      SizedBox(
                        height: 170.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: transferState.Transfer.length + 1,
                          itemBuilder: (context, index) {
                            if (index < transferState.Transfer.length) {
                              return PlayerTransferCard(
                                playerTransfer: transferState.Transfer[index],
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MultiProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (_) => TransferBloc()
                                              ..add(TransferRequested()),
                                          ),
                                          BlocProvider(
                                            create: (_) => NewsBloc()
                                              ..add(TransferNewsRequested(
                                                  language:
                                                      localLanguageNotifier
                                                          .value)),
                                          ),
                                        ],
                                        child: const Transfertab(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: CircleAvatar(
                                    radius: 15.sp,
                                    backgroundColor: Colorscontainer.greyShade
                                        .withOpacity(0.4),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colorscontainer.greenColor,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    if (newsState.transfernewsStatus ==
                        NewsRequest.requestInProgress)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    if (newsState.transfernewsStatus ==
                            NewsRequest.requestFailure &&
                        newsState.counter < 2)
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 85.h),
                            Image.asset(
                              'assets/404.gif',
                              height: 200.h,
                              fit: BoxFit.fitHeight,
                              width: 300.w,
                              color: Colorscontainer.greenColor,
                            ),
                            Text(
                              DemoLocalizations.networkProblem,
                              style: TextUtils.setTextStyle(
                                color: Colorscontainer.greenColor,
                                fontSize: 15.sp,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _refresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                DemoLocalizations.tryAgain,
                                style: TextUtils.setTextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            const SizedBox(height: 56),
                          ],
                        ),
                      ),
                    if (newsState.transfernewsStatus ==
                            NewsRequest.requestSuccess ||
                        newsState.transfernews.isNotEmpty)
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: newsState.transfernews.length,
                        itemBuilder: (context, index) {
                          if (index == newsState.transfernews.length &&
                              isLoadingNextPage) {
                            return const ShimmerNewsCard();
                          } else if (index < newsState.transfernews.length) {
                            final news = newsState.transfernews[index];
                            return NewsCard(news: news);
                          } else {
                            return Container();
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlayerTransferCard extends StatelessWidget {
  final TransferModel playerTransfer;

  const PlayerTransferCard({super.key, required this.playerTransfer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlayerImage(),
              const SizedBox(height: 4),
              _buildPlayerName(context),
              const SizedBox(height: 4),
              _buildTransferDetails(context),
              const SizedBox(height: 4),
              _buildTransferAmount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          playerTransfer.playerProfile,
          height: 70.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 70.h,
              color: Colors.grey,
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 24.sp,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerName(context) {
    String playerName = playerTransfer.playerName.englishName;
    if (localLanguageNotifier.value == 'am') {
      playerName = playerTransfer.playerName.amharicName;
    } else if (localLanguageNotifier.value == 'or') {
      playerName = playerTransfer.playerName.oromoName;
    } else if (localLanguageNotifier.value == 'tr') {
      playerName = playerTransfer.playerName.amharicName;
    } else if (localLanguageNotifier.value == 'so') {
      playerName = playerTransfer.playerName.somaliName;
    }

    return Center(
      child: Text(
        playerName,
        style: TextUtils.setTextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTransferDetails(context) {
    String fromclubname = playerTransfer.fromClubName.englishName;
    String toclubname = playerTransfer.toClubName.englishName;

    if (localLanguageNotifier.value == 'am') {
      fromclubname = playerTransfer.fromClubName.amharicName;
      toclubname = playerTransfer.toClubName.amharicName;
    } else if (localLanguageNotifier.value == 'or') {
      fromclubname = playerTransfer.fromClubName.oromoName;
      toclubname = playerTransfer.toClubName.oromoName;
    } else if (localLanguageNotifier.value == 'tr') {
      fromclubname = playerTransfer.fromClubName.amharicName;
      toclubname = playerTransfer.toClubName.amharicName;
    } else if (localLanguageNotifier.value == 'so') {
      fromclubname = playerTransfer.fromClubName.somaliName;
      toclubname = playerTransfer.toClubName.somaliName;
    }

    return Row(
      children: [
        _buildClubLogo(playerTransfer.fromClubName.logo),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildClubName(fromclubname, TextAlign.left, context),
        ),
        Icon(Icons.arrow_forward, size: 16.sp),
        Expanded(
          child: _buildClubName(toclubname, TextAlign.right, context),
        ),
        SizedBox(width: 4.w),
        _buildClubLogo(playerTransfer.toClubName.logo),
      ],
    );
  }

  Widget _buildClubLogo(String logo) {
    return Image.network(
      logo,
      width: 20.w,
      height: 20.h,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: 20.h,
          width: 20.w,
          child: Image.asset('assets/club-icon.png'),
        );
      },
    );
  }

  Widget _buildClubName(String name, TextAlign align, context) {
    return Text(
      name,
      style: TextUtils.setTextStyle(
        fontSize: 11.sp,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: align,
    );
  }

  Widget _buildTransferAmount(context) {
    String transferAmount = playerTransfer.transferAmount;
    if (transferAmount.toLowerCase() == 'free transfer') {
      switch (localLanguageNotifier.value) {
        case 'am':
          transferAmount = 'ነፃ ዝውውር';
          break;
        case 'or':
          transferAmount = 'bilisa';
          break;
        case 'so':
          transferAmount = 'bilaasha';
          break;
        case 'tr':
          transferAmount = 'ነፃ ዝውውር';
          break;
        default:
          transferAmount = 'Free Transfer'; // Fallback to English
      }
    }

    return SizedBox(
      height: 20.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              transferAmount,
              style: TextUtils.setTextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    String? description = news.summarizedTitle;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewsDetailPage(
            news: news,
          ),
        ));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl:
                      news.mainImages.isNotEmpty ? news.mainImages[0].url : '',
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/testa_logo.png'),
                  cacheManager: CacheManager(
                    Config(
                      'cacheKey',
                      stalePeriod: const Duration(days: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Ensure column shrinks to fit content
                  children: [
                    Text(
                      description ?? '',
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    SizedBox(
                        height: 12
                            .h), // Add some space between the text and the row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            news.sourcename ?? '',
                            style: TextUtils.setTextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' ${formatTimeForNews(news.publishedDate ?? '')}',
                          style: TextUtils.setTextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerNewsCard extends StatelessWidget {
  const ShimmerNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                color: Colors.white,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      height: 16.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 100.w,
                      height: 16.h,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
