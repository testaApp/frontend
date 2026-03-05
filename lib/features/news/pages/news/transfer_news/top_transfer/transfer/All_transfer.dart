import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_bloc.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_event.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_state.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_widget.dart';

class Transferdetail extends StatefulWidget {
  final String RssLink;
  final bool isMainPage;
  const Transferdetail({super.key, this.RssLink = '', this.isMainPage = true});

  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transferdetail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<TransferBloc>().add(TransferRequested());
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    final currentPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final shouldLoadNextPage = currentPosition >= maxScrollExtent - 180;

    if (shouldLoadNextPage) {
      context.read<TransferBloc>().add(LoadNextTransferPage());
    }
  }

  Future<void> _refresh() async {
    context.read<TransferBloc>().add(TransferRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = Colorscontainer.greenColor;
    return RefreshIndicator(
      color: accent,
      backgroundColor: isLight ? Colors.white : Colors.black,
      onRefresh: _refresh,
      child: BlocBuilder<TransferBloc, TransferState>(
        builder: (context, state) {
          if (state.status == TransferStatus.loading &&
              state.transfers.isEmpty) {
            return ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10.h, bottom: 24.h),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: SizedBox(
                      width: 90.w,
                      child: Image.asset(
                        'assets/transfer.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (state.status == TransferStatus.failure &&
              state.transfers.isEmpty) {
            return ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 40.h, bottom: 24.h),
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 48.sp, color: accent),
                      SizedBox(height: 12.h),
                      Text(
                        DemoLocalizations.networkProblem ??
                            'Connection Issue',
                        style: TextUtils.setTextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      OutlinedButton(
                        onPressed: _refresh,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent.withOpacity(0.5)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 10.h, bottom: 24.h),
            itemCount: state.transfers.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, idx) {
              if (idx < state.transfers.length) {
                return TransferWgt(
                  transferModel: state.transfers[idx],
                  mode: TransferCardMode.list,
                );
              }
              return _TransferLoadingShimmer(isLight: isLight);
            },
          );
        },
      ),
    );
  }
}

class _TransferLoadingShimmer extends StatelessWidget {
  final bool isLight;
  const _TransferLoadingShimmer({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final baseColor = isLight ? Colors.grey[200]! : Colors.grey[850]!;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.grey[700]!;
    final cardColor = isLight ? Colors.white : Colors.grey[900]!;
    final blockColor = isLight ? Colors.grey[200]! : Colors.grey[800]!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              Container(
                width: 100.w,
                height: 140.h,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    bottomLeft: Radius.circular(18.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.h,
                      color: blockColor,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 120.w,
                      height: 12.h,
                      color: blockColor,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: 80.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
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
