import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:blogapp/state/bloc/news/news_bloc.dart';
import 'package:blogapp/state/bloc/news/news_event.dart';
import 'package:blogapp/state/bloc/news/news_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/news/pages/news/main_news/news_row.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/Transfertab.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_widget.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_bloc.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_event.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_state.dart';

class TransferPage extends StatefulWidget {
  final Function(double) onScroll;
  const TransferPage({super.key, required this.onScroll});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    context.read<TransferBloc>().add(TransferRequested());
    context.read<NewsBloc>().add(
      TransferNewsRequested(language: localLanguageNotifier.value),
    );
  }

  void _scrollListener() {
    widget.onScroll(_scrollController.offset);

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingNextPage) {
      setState(() => _isLoadingNextPage = true);
      context.read<NewsBloc>().add(
        TransferLoadnextNewsRequested(language: localLanguageNotifier.value),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _isLoadingNextPage = false);
      });
    }
  }

  Future<void> _refresh() async {
    context.read<TransferBloc>().add(TransferRequested());
    context.read<NewsBloc>().add(
      TransferNewsRequested(language: localLanguageNotifier.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final accent = Colorscontainer.greenColor;

    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isLight
          ? const [Color(0xFFF9FBFD), Color(0xFFEAF7F2), Color(0xFFF9FBFD)]
          : const [Color(0xFF0B0F17), Color(0xFF071612), Color(0xFF0B0F17)],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          DemoLocalizations.transfer_window,
          style: TextUtils.setTextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            Positioned(top: -160, right: -100, child: _buildGlow(accent.withOpacity(0.16), 280)),
            Positioned(bottom: -180, left: -120, child: _buildGlow(accent.withOpacity(0.12), 320)),

            SafeArea(
              child: RefreshIndicator(
                color: accent,
                backgroundColor: isLight ? Colors.white : const Color(0xFF10151D),
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: 8.h)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: accent.withOpacity(0.2)),
                              ),
                              child: Text(
                                "MERCATO",
                                style: TextUtils.setTextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              DemoLocalizations.transfer_window,
                              style: TextUtils.setTextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w900,
                                color: isLight ? Colors.black : Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Premium deals, rumors and confirmed moves',
                              style: TextUtils.setTextStyle(
                                fontSize: 13.sp,
                                color: isLight ? Colors.black45 : Colors.white54,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    BlocBuilder<TransferBloc, TransferState>(
                      builder: (context, state) {
                        if (state.status != TransferStatus.success || state.transfers.isEmpty) {
                          return const SliverToBoxAdapter(child: SizedBox.shrink());
                        }
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Latest Transfers",
                                  style: TextUtils.setTextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isLight ? Colors.black87 : Colors.white,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20.r),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MultiProvider(
                                            providers: [
                                              BlocProvider(create: (_) => TransferBloc()..add(TransferRequested())),
                                              BlocProvider(create: (_) => NewsBloc()..add(TransferNewsRequested(language: localLanguageNotifier.value))),
                                            ],
                                            child: Transfertab(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      child: Row(
                                        children: [
                                          Text(
                                            "See all",
                                            style: TextUtils.setTextStyle(
                                              fontSize: 13.sp,
                                              color: accent,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: accent),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    BlocBuilder<TransferBloc, TransferState>(
                      builder: (context, state) {
                        if (state.status == TransferStatus.loading && state.transfers.isEmpty) {
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: 215.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 280.w,
                                    decoration: BoxDecoration(
                                      color: isLight ? Colors.white : const Color(0xFF11171F),
                                      borderRadius: BorderRadius.circular(28.r),
                                      border: Border.all(color: accent.withOpacity(0.15)),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                                itemCount: 3,
                              ),
                            ),
                          );
                        }
                        if (state.status != TransferStatus.success) {
                          return const SliverToBoxAdapter(child: SizedBox.shrink());
                        }
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            height: 215.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: state.transfers.length,
                              itemBuilder: (context, index) {
                                return TransferWgt(
                                  transferModel: state.transfers[index],
                                  mode: TransferCardMode.highlight,
                                  width: 280.w,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "Transfer News & Rumours",
                          style: TextUtils.setTextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: isLight ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 6.h)),

                    BlocBuilder<NewsBloc, NewsState>(
                      builder: (context, state) {
                        if (state.transfernewsStatus == NewsRequest.requestInProgress && state.transfernews.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: _LoadingAnimation(accent: accent)),
                          );
                        }

                        if (state.transfernews.isEmpty && state.transfernewsStatus == NewsRequest.requestFailure) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: _ErrorRetryView(onRetry: _refresh),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < state.transfernews.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                                  child: Newsinrow(news: state.transfernews[index]),
                                );
                              }
                              if (_isLoadingNextPage) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: state.transfernews.length + (_isLoadingNextPage ? 1 : 0),
                          ),
                        );
                      },
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent], stops: const [0.25, 1.0]),
      ),
    );
  }
}


class _LoadingAnimation extends StatelessWidget {
  final Color accent;
  const _LoadingAnimation({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/transfer.json',
      width: 120.w,
      height: 120.h,
      fit: BoxFit.contain,
      delegates: LottieDelegates(
        values: [ValueDelegate.colorFilter(['**'], value: ColorFilter.mode(accent, BlendMode.srcATop))],
      ),
    );
  }
}

class _ErrorRetryView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetryView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/404.gif', height: 200.h, fit: BoxFit.fitHeight),
          SizedBox(height: 24.h),
          Text(
            DemoLocalizations.networkProblem ?? "Connection Issue",
            style: TextUtils.setTextStyle(fontSize: 16.sp, color: Colorscontainer.greenColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorscontainer.greenColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
            ),
          ),
        ],
      ),
    );
  }
}

