import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_bloc.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_State.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/features/tv/pages/Tv/highlight/highlight-special-card.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class RecentHighlightsSection extends StatelessWidget {
  const RecentHighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HighlightTvBloc, HighlightTvState>(
      builder: (context, state) {
        if (state is HighlightTvLoaded && state.recentHighlights.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildHighlightsList(state),
              SizedBox(height: 16.h),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the header section with an icon and title.
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.sportscourt,
            size: 16.sp,
            color: Colors.grey[700],
          ),
          SizedBox(width: 6.w),
          Text(
            DemoLocalizations.highlight ?? 'Highlights',
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal list of recent highlights.
  Widget _buildHighlightsList(HighlightTvLoaded state) {
    return SizedBox(
      height: 230.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.recentHighlights.length,
        itemBuilder: (context, index) {
          final highlight = state.recentHighlights[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SizedBox(
              width: 300.w,
              child: HighlightSpecialCard(
                videoUrl: highlight.video ?? '',
                description: highlight.description,
              ),
            ),
          );
        },
      ),
    );
  }
}
