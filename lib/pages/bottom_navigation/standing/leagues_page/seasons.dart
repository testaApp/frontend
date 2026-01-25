import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/seasons_page/seasons_page_bloc.dart';
import '../../../../application/seasons_page/seasons_page_event.dart';
import '../../../../application/seasons_page/seasons_page_state.dart';
import '../../../constants/text_utils.dart';
import 'seasons/seasons_table_view.dart';

class SeasonsPage extends StatefulWidget {
  final int leagueId;
  const SeasonsPage({super.key, required this.leagueId});

  @override
  State<SeasonsPage> createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
  @override
  initState() {
    context
        .read<SeasonsPageBloc>()
        .add(LeagueWinnersRequested(widget.leagueId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeasonsPageBloc, SeasonsPageState>(
      builder: (context, state) {
        return state.status == SeasonsPageStatus.loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.status == SeasonsPageStatus.error
                ? Center(
                    child: Text(
                      'Error',
                      style: TextUtils.setTextStyle(color: Colors.white),
                    ),
                  )
                : state.winners.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 50.h),
                        itemCount: state.winners.length,
                        itemBuilder: (context, index) {
                          final item = state.winners[index];
                          int itemLength = item.length > 4 ? 4 : item.length;
                          return SeasonsTablesView(
                              listOfTables: item.sublist(0, itemLength),
                              onRefresh: () {});
                        },
                      );
      },
    );
  }
}
