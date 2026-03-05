import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/leagues_page/top_scorer.model.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/shared/constants/text_utils.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final TopScorerModel player;
  final String deviceLanguage;

  const PlayerDetailsDialog({
    super.key,
    required this.player,
    required this.deviceLanguage,
  });

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  Color? dominantColor;

  @override
  void initState() {
    super.initState();
    _loadDominantColor();
  }

  Future<void> _loadDominantColor() async {
    final color = await _getDominantColor(widget.player.teamLogo);
    setState(() {
      dominantColor = color;
    });
  }

  Future<Color> _getDominantColor(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
      );
      return paletteGenerator.dominantColor?.color ??
          Colorscontainer.greenColor;
    } catch (e) {
      return Colorscontainer.greenColor;
    }
  }

  String getLocalizedName() {
    if (widget.deviceLanguage == 'am' || widget.deviceLanguage == 'tr') {
      return widget.player.name.amharicName?.isNotEmpty == true
          ? widget.player.name.amharicName!
          : widget.player.name.englishName ?? '';
    } else if (widget.deviceLanguage == 'or') {
      return widget.player.name.oromoName?.isNotEmpty == true
          ? widget.player.name.oromoName!
          : widget.player.name.englishName ?? '';
    } else if (widget.deviceLanguage == 'so') {
      return widget.player.name.somaliName?.isNotEmpty == true
          ? widget.player.name.somaliName!
          : widget.player.name.englishName ?? '';
    }
    return widget.player.name.englishName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.85.sw,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player image and header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        dominantColor ?? Colorscontainer.greenColor,
                        (dominantColor ?? Colorscontainer.greenColor)
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40.h,
                  child: CircleAvatar(
                    radius: 45.r,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42.r,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.player.pic),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20.h,
                  right: 20.w,
                  child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 23.r,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 21.r,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.player.teamLogo),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 45.h),

            // Player name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                getLocalizedName(),
                style: TextUtils.setTextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            SizedBox(height: 20.h),

            // Stats grid
            Padding(
              padding: EdgeInsets.all(16.w),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                children: [
                  _buildStatCard(
                    context,
                    DemoLocalizations.goalsScored,
                    widget.player.goal.toString(),
                    'assets/ball.png',
                  ),
                  _buildStatCard(
                    context,
                    DemoLocalizations.topAssist,
                    widget.player.assists?.toString() ?? '0',
                    'assets/chama.png',
                  ),
                  _buildStatCard(
                    context,
                    DemoLocalizations.yellowRedCards,
                    widget.player.yellow?.toString() ?? '0',
                    'assets/yellow_card.png',
                  ),
                  _buildStatCard(
                    context,
                    DemoLocalizations.redCard,
                    widget.player.red?.toString() ?? '0',
                    'assets/red_card.png',
                  ),
                  _buildStatCard(
                    context,
                    DemoLocalizations.penality,
                    widget.player.penality?.toString() ?? '0',
                    'assets/penality.png',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String iconPath,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (dominantColor ?? Colorscontainer.greenColor).withOpacity(0.15),
            (dominantColor ?? Colorscontainer.greenColor).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                width: 14.w,
                height: 14.w,
              ),
              SizedBox(width: 4.w),
              Text(
                value,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colorscontainer.greenColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
