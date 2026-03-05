import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AdWidget extends StatelessWidget {
  final Map<String, String> ad;

  const AdWidget({
    super.key,
    required this.ad,
  });

  @override
  Widget build(BuildContext context) {
    if (ad['image'] == null ||
        ad['image']!.isEmpty ||
        ad['url'] == null ||
        ad['url']!.isEmpty) {
      return SizedBox(height: 20.h);
    }

    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(ad['url']!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.r),
          child: CachedNetworkImage(
            imageUrl: ad['image']!,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                height: 200.h,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
