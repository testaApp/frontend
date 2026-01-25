import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'scorer_row.dart';
import '../constants/colors.dart';
import '../../models/leagues_page/top_scorer.model.dart';

class ListMaker extends StatelessWidget {
  final List<TopScorerModel> topScorers;
  final int leagueId;
  final String logo;
  final String type;

  const ListMaker({
    super.key,
    required this.topScorers,
    required this.leagueId,
    required this.logo,
    required this.type,
  });

  void _showFullList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    itemCount: topScorers.length,
                    itemBuilder: (context, index) {
                      int rank = _calculateRank(index);
                      return Column(
                        children: [
                          ScorerRow(
                            rank: rank,
                            scorerModel: topScorers[index],
                            index: index,
                            removeNumber: false,
                          ),
                          if (index < topScorers.length - 1)
                            Divider(height: 16.h, thickness: 0.5),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateRank(int index) {
    if (index == 0) return 1;

    if (topScorers[index].goal == topScorers[index - 1].goal) {
      return _calculateRank(index - 1);
    }
    return index + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => Divider(height: 16.h, thickness: 0.5),
            itemBuilder: (context, index) {
              int rank = _calculateRank(index);
              return ScorerRow(
                rank: rank,
                scorerModel: topScorers[index],
                index: index,
                removeNumber: false,
              );
            },
          ),
          InkWell(
            onTap: () => _showFullList(context),
            child: Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24.sp,
                color: Colorscontainer.greenColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
