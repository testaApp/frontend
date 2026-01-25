import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'transfer_bloc.dart';
import 'transfer_event.dart';
import 'transfer_model.dart';
import 'transfer_state.dart';
import 'transfer_widget.dart';

class Transferdetail extends StatefulWidget {
  final String RssLink;
  final bool isMainPage;
  const Transferdetail({super.key, this.RssLink = '', this.isMainPage = true});

  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transferdetail> {
  int selectedIndex = 0;
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
    final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100;

    if (shouldLoadNextPage) {
      context.read<TransferBloc>().add(LoadNextTransferPage());
    }
  }

  Future<void> _refresh() async {
    context.read<TransferBloc>().add(TransferRequested());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              if (state.status == Transferstatus.requested) {
                return SizedBox(
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
                );
              } else if (state.status == Transferstatus.requestSuccess) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.Transfer.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, idx) {
                    TransferModel transferModel = state.Transfer[idx];
                    return TransferWgt(transferModel: transferModel);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              if (state.isLastPage ||
                  state.status == Transferstatus.requested) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Shimmer.fromColors(
                  baseColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  highlightColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  child: Container(
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 180.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomLeft: Radius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20.h,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: 100.w,
                                height: 16.h,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  Container(
                                    width: 80.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
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
            },
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
