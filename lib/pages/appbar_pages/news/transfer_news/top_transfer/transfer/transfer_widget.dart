import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../localization/demo_localization.dart';
import '../../../../../../main.dart';
import '../../../../../constants/colors.dart';
import 'transfer_model.dart';

class TransferWgt extends StatelessWidget {
  final TransferModel transferModel;
  const TransferWgt({super.key, required this.transferModel});

  @override
  Widget build(BuildContext context) {
    String playerName = transferModel.playerName.englishName;
    String teamName = transferModel.fromClubName.englishName;
    String toClubName = transferModel.toClubName.englishName;

    String deviceLanguage = localLanguageNotifier.value;

    if ((deviceLanguage == 'am' || deviceLanguage == 'tr') &&
        transferModel.playerName.amharicName.isNotEmpty &&
        transferModel.fromClubName.amharicName.isNotEmpty &&
        transferModel.toClubName.amharicName.isNotEmpty) {
      playerName = transferModel.playerName.amharicName;
      teamName = transferModel.fromClubName.amharicName;
      toClubName = transferModel.toClubName.amharicName;
    } else if (deviceLanguage == 'or' &&
        transferModel.playerName.oromoName.isNotEmpty &&
        transferModel.fromClubName.oromoName.isNotEmpty &&
        transferModel.toClubName.oromoName.isNotEmpty) {
      playerName = transferModel.playerName.oromoName;
      teamName = transferModel.fromClubName.oromoName;
      toClubName = transferModel.toClubName.oromoName;
    } else if (deviceLanguage == 'so' &&
        transferModel.playerName.somaliName.isNotEmpty &&
        transferModel.fromClubName.somaliName.isNotEmpty &&
        transferModel.toClubName.somaliName.isNotEmpty) {
      playerName = transferModel.playerName.somaliName;
      teamName = transferModel.fromClubName.somaliName;
      toClubName = transferModel.toClubName.somaliName;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colorscontainer.greyShade2,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildPlayerInfo(playerName),
            ),
            Expanded(
              flex: 3,
              child: _buildTransferInfo(teamName, toClubName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String playerName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: CachedNetworkImage(
            imageUrl: transferModel.playerName.photo!,
            height: 140.h,
            width: 110.w,
            fit: BoxFit.cover,
            // placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Image.asset('assets/playershimmer.png'),
          ),
        ),
        Text(
          playerName,
          style: GoogleFonts.abyssinicaSil(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTransferInfo(String fromClubName, String toClubName) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoRow(
              DemoLocalizations.nationality, transferModel.nationalitylogo),
          _buildInfoRow(DemoLocalizations.age, transferModel.age),
          _buildInfoRow(DemoLocalizations.position, transferModel.position),
          _buildClubTransfer(fromClubName, toClubName),
          Center(
            child: Text(
              transferModel.transferAmount.toString(),
              style: GoogleFonts.abyssinicaSil(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: GoogleFonts.abyssinicaSil(
              color: Colors.grey,
              fontSize: 10.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 10.w),
        if (label == DemoLocalizations.nationality)
          CachedNetworkImage(
            imageUrl: value,
            width: 20.w,
            height: 20.h,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 20.w,
                height: 20.h,
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        else
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.abyssinicaSil(
                color: Colors.white,
                fontSize: 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildClubTransfer(String fromClubName, String toClubName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: _buildClubInfo(transferModel.fromClubName.logo, fromClubName),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Icon(
              Icons.keyboard_double_arrow_right,
              size: 30.r,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildClubInfo(transferModel.toClubName.logo, toClubName),
        ),
      ],
    );
  }

  Widget _buildClubInfo(String logoUrl, String clubName) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: logoUrl,
          width: 30.w,
          height: 30.h,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        SizedBox(height: 5.h),
        Text(
          clubName,
          style: GoogleFonts.abyssinicaSil(
            color: Colors.white,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
