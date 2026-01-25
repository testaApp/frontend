import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../models/standings/standings.dart';
import '../../../../../widgets/standing_table_teams_list.dart';
import '../../../../constants/text_utils.dart';
import '../Standing/rank_name_others_line.dart';

class SeasonsTablesView extends StatelessWidget {
  final List<List<TableItem>> listOfTables;
  final Function onRefresh;
  const SeasonsTablesView(
      {super.key, required this.listOfTables, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final nameWidth = MediaQuery.of(context).size.width / 2.4;
    return RefreshIndicator(
      onRefresh: () async {
        //  onRefresh();
      },
      child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
              indent: 2, endIndent: 2, height: 1.5.h, color: Colors.grey[700]),
          shrinkWrap: true,
          itemCount: listOfTables.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, idx) {
            String? season = listOfTables[idx][0].season;
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(season ?? '',
                      style: TextUtils.setTextStyle(
                          fontSize: 17.sp, color: Colors.grey)),
                ),
                FirstRow(nameWidth: nameWidth),
                ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                      indent: 2,
                      endIndent: 2,
                      height: 1.5.h,
                      color: Colors.grey[700]),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: listOfTables[idx].length > 4
                      ? 4
                      : listOfTables[idx].length,
                  itemBuilder: (context, index) {
                    final tableItem = listOfTables[idx][index];

                    return tablesItem(context, tableItem, nameWidth,
                        Colors.black.withOpacity(0));
                  },
                ),
                Container(
                  height: 10.h,
                  width: 360.w,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                      border: Border.all(
                        // bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.7,

                        // )
                      )),
                ),
                SizedBox(
                  height: 10.h,
                )
              ],
            );
          }),
    );
  }
}
