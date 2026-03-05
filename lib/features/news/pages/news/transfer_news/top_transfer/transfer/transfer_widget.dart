import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';

enum TransferCardMode { list, highlight }

class TransferWgt extends StatelessWidget {
  final TransferModel transferModel;
  final TransferCardMode mode;
  final double? width;

  const TransferWgt({
    super.key,
    required this.transferModel,
    this.mode = TransferCardMode.list,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = Colorscontainer.greenColor;
    final lang = localLanguageNotifier.value;

    if (mode == TransferCardMode.highlight) {
      return _buildHighlightCard(context, isLight, accent, lang);
    }
    return _buildListCard(context, isLight, accent, lang);
  }

  Widget _buildHighlightCard(BuildContext context, bool isLight, Color accent, String lang) {
    final playerImage = transferModel.resolvedPlayerImage();
    final playerName = transferModel.localizedPlayerName(lang);
    final fromClub = transferModel.localizedClubName(transferModel.fromClubName, lang);
    final toClub = transferModel.localizedClubName(transferModel.toClubName, lang);
    final amount = transferModel.normalizedTransferAmount(lang);

    return Container(
      width: width ?? 280.w,
      margin: EdgeInsets.only(right: 16.w, top: 4.h, bottom: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: isLight ? Colors.white : const Color(0xFF1C222D),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            // Decorative Background Gradient
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section: Image & Clubs
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _PlayerImage(
                          imageUrl: playerImage,
                          isLight: isLight,
                          accent: accent,
                          isRound: false,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (isLight ? Colors.white : const Color(0xFF1C222D)).withOpacity(0.7),
                                (isLight ? Colors.white : const Color(0xFF1C222D)),
                              ],
                              stops: const [0.5, 0.88, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Floating Elements
                      Positioned(
                        top: 14.h,
                        right: 14.w,
                        child: _AmountPill(label: amount, accent: accent),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 16.w,
                        child: Row(
                          children: [
                            _ClubLogo(url: transferModel.fromClubName.logo, size: 28.w),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: accent),
                            ),
                            _ClubLogo(url: transferModel.toClubName.logo, size: 28.w),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Section: Info
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerName.toUpperCase(),
                              style: TextUtils.setTextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "$fromClub ➔ $toClub",
                              style: TextUtils.setTextStyle(
                                fontSize: 10.5.sp,
                                color: isLight ? Colors.black54 : Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (transferModel.age.isNotEmpty && transferModel.age != '0')
                              _MiniTag(label: "${transferModel.age} YRS", isLight: isLight),
                            if (transferModel.age.isNotEmpty && transferModel.age != '0' && transferModel.position.isNotEmpty)
                              SizedBox(width: 6.w),
                            if (transferModel.position.isNotEmpty)
                              _MiniTag(label: transferModel.position.toUpperCase(), isLight: isLight),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, bool isLight, Color accent, String lang) {
    final playerImage = transferModel.resolvedPlayerImage();
    final playerName = transferModel.localizedPlayerName(lang);
    final fromClub = transferModel.localizedClubName(transferModel.fromClubName, lang);
    final toClub = transferModel.localizedClubName(transferModel.toClubName, lang);
    final amount = transferModel.normalizedTransferAmount(lang);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E2632),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _PlayerImage(
            imageUrl: playerImage,
            isLight: isLight,
            accent: accent,
            width: 72.w,
            height: 72.w,
            isRound: true,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        playerName,
                        style: TextUtils.setTextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _AmountPill(label: amount, accent: accent, isSmall: true),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _ClubLogo(url: transferModel.fromClubName.logo, size: 22.w),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_right_alt_rounded, size: 16.sp, color: accent.withOpacity(0.8)),
                    SizedBox(width: 8.w),
                    _ClubLogo(url: transferModel.toClubName.logo, size: 22.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "$fromClub to $toClub".toUpperCase(),
                        style: TextUtils.setTextStyle(
                          fontSize: 10.sp,
                          color: isLight ? Colors.black54 : Colors.white54,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (transferModel.position.isNotEmpty || (transferModel.age.isNotEmpty && transferModel.age != '0')) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      if (transferModel.age.isNotEmpty && transferModel.age != '0')
                        _MiniTag(label: "${transferModel.age} YRS", isLight: isLight),
                      if (transferModel.age.isNotEmpty && transferModel.age != '0' && transferModel.position.isNotEmpty)
                        SizedBox(width: 8.w),
                      if (transferModel.position.isNotEmpty)
                        _MiniTag(label: transferModel.position.toUpperCase(), isLight: isLight),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerImage extends StatelessWidget {
  final String imageUrl;
  final bool isLight;
  final Color accent;
  final double? width;
  final double? height;
  final bool isRound;

  const _PlayerImage({
    required this.imageUrl,
    required this.isLight,
    required this.accent,
    this.width,
    this.height,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: isRound ? BoxShape.circle : BoxShape.rectangle,
        color: isLight ? Colors.grey[100] : Colors.grey[900],
        border: Border.all(color: accent.withOpacity(0.1), width: 1),
      ),
      child: isRound 
        ? ClipOval(child: _buildNetworkImage(context))
        : ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: _buildNetworkImage(context),
          ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: isLight ? Colors.grey[200]! : Colors.grey[800]!,
        highlightColor: isLight ? Colors.grey[50]! : Colors.grey[700]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.person,
        color: isLight ? Colors.grey[300] : Colors.grey[700],
        size: 32.sp,
      ),
    );
  }
}

extension on Widget {
  Widget circular(bool enabled) {
    if (!enabled) return this;
    return ClipOval(child: this);
  }
}

class _ClubLogo extends StatelessWidget {
  final String? url;
  final double size;

  const _ClubLogo({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(2.w),
      child: CachedNetworkImage(
        imageUrl: url ?? '',
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => Icon(Icons.shield, size: size * 0.6, color: Colors.grey),
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final String label;
  final Color accent;
  final bool isSmall;

  const _AmountPill({required this.label, required this.accent, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final isFree = label.toLowerCase().contains('free') || label.contains('ነጻ');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8.w : 12.w, vertical: isSmall ? 3.h : 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFree
              ? [const Color(0xFF607D8B), const Color(0xFF455A64)]
              : [accent, accent.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: (isFree ? Colors.blueGrey : accent).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextUtils.setTextStyle(
          fontSize: isSmall ? 10.sp : 11.5.sp,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final bool isLight;

  const _MiniTag({required this.label, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey[100] : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: isLight ? Colors.grey[300]! : Colors.white12),
      ),
      child: Text(
        label,
        style: TextUtils.setTextStyle(
          fontSize: 9.sp,
          color: isLight ? Colors.black54 : Colors.white54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
