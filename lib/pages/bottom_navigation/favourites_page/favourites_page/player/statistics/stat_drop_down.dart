import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../domain/player/playerStatisticsModel.dart';
import '../../../../../../main.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/text_utils.dart';

class PlayerstatDropdown extends StatefulWidget {
  List<PlayerStatistics> playerStats;
  final Function setIndex;
  final int index;

  PlayerstatDropdown(
      {super.key,
      required this.playerStats,
      required this.index,
      required this.setIndex});

  @override
  State<PlayerstatDropdown> createState() => _PlayerstatDropdownState();
}

class _PlayerstatDropdownState extends State<PlayerstatDropdown> {
  late List<String> leaguePhotos;
  late List<String> teamPics;
  late List<String> teamNames;

  @override
  initState() {
    super.initState();
    leaguePhotos =
        widget.playerStats.map((stat) => stat.leaguePhoto ?? '').toList();
    teamPics = widget.playerStats.map((stat) => stat.teamPhoto ?? '').toList();
    teamNames = widget.playerStats
        .map((stat) => _getLocalizedLeagueName(stat))
        .toList();
  }

  String _getLocalizedLeagueName(PlayerStatistics stat) {
    final deviceLanguage = localLanguageNotifier.value;

    switch (deviceLanguage) {
      case 'am':
        return stat.amharicLeagueName ?? stat.englishLeagueName ?? '';
      case 'or':
        return stat.oromoLeagueName ?? stat.englishLeagueName ?? '';
      case 'si':
        return stat.somaliLeagueName ?? stat.englishLeagueName ?? '';
      default:
        return stat.englishLeagueName ?? '';
    }
  }

  void onChanged(String? newValue) {
    if (newValue != null) {
      widget.setIndex(teamNames.indexOf(newValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        enableFeedback: true,
        style: TextUtils.setTextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 14.sp),
        hint: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 15.w,
              child: CachedNetworkImage(
                imageUrl: leaguePhotos[widget.index] ?? '',
                errorWidget: (context, url, error) => Icon(
                  Icons.sports_soccer_rounded,
                  color: Colorscontainer.greenColor,
                ),
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            SizedBox(
              width: 15.w,
              child: CachedNetworkImage(
                  imageUrl: teamPics[widget.index] ?? '',
                  errorWidget: (context, url, error) => Icon(
                        Icons.sports_soccer_rounded,
                        color: Colorscontainer.greenColor,
                      )),
            ),
            SizedBox(
              width: 5.w,
            ),
            Expanded(
              child: Text(
                teamNames[widget.index] ?? '',
                style: TextUtils.setTextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        isExpanded: true,
        items: teamNames
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5.w,
                      ),
                      SizedBox(
                        width: 15.w,
                        child: CachedNetworkImage(
                            imageUrl:
                                leaguePhotos[teamNames.indexOf(value)] ?? '',
                            errorWidget: (context, url, error) => Container()),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      SizedBox(
                        width: 15.w,
                        child: CachedNetworkImage(
                            imageUrl: teamPics[teamNames.indexOf(value)] ?? '',
                            errorWidget: (context, url, error) => Container()),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Text(
                          value,
                          style: TextUtils.setTextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  )),
            )
            .toList(),
        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          width: MediaQuery.of(context).size.width * 100,
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.surface,
          ),
          elevation: 2,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
          ),
          iconSize: 24.sp,
          iconEnabledColor: Colorscontainer.greenColor,
          iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 320.h,
          width: MediaQuery.of(context).size.width * 0.952,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.surface,
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
      ),
    );
  }
}
