import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/dominant_color_generator.dart';
import '../../pages/constants/text_utils.dart';

class FavPlayerContainer extends StatefulWidget {
  final String? imageUrl;
  final String? name;
  final String? imageUrl2;
  final String? imageUrl3;
  final int? number1;
  final int? number2;
  final int id;
  final Color? nameColor; // Add the nameColor parameter

  const FavPlayerContainer({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.imageUrl2,
    required this.imageUrl3,
    required this.number1,
    required this.number2,
    required this.id,
    this.nameColor, // Set a default value if needed
  });

  @override
  State<FavPlayerContainer> createState() => _FavPlayerContainerState();
}

class _FavPlayerContainerState extends State<FavPlayerContainer> {
  Color? dominantColor;
  @override
  void initState() {
    print('id is ${widget.id}');
    _generateDominantColor();
    super.initState();
  }

  Future<void> _generateDominantColor() async {
    Color teamColor =
        await generateDominantColor(imageUrl: widget.imageUrl2 ?? '');

    setState(() {
      dominantColor = teamColor.withOpacity(0.3);
      //print("updated");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyComponent(
      imageUrl2: widget.imageUrl2,
      imageUrl3: widget.imageUrl3,
      number1: widget.number1,
      number2: widget.number2,
      imageUrl: widget.imageUrl,
      name: widget.name,
      dominantColor: dominantColor ?? Colors.transparent,
      id: widget.id,
      nameColor: widget.nameColor, // Pass the nameColor parameter
    );
  }
}

class MyComponent extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? imageUrl2;
  final String? imageUrl3;
  final int? number1;
  final int? number2;
  final int id;
  final Color dominantColor;
  final Color? nameColor; // Add the nameColor parameter

  const MyComponent({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.imageUrl2,
    required this.imageUrl3,
    required this.number1,
    required this.number2,
    required this.dominantColor,
    this.nameColor, // Set a default value if needed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(children: [
        const SizedBox(
          height: 10,
        ),
        Center(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
              ),
              width: 170,
              height: 170,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            imageUrl2 ?? '',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: dominantColor,
                        // Use the dominant color for the shade
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.w,
                    left: 10.w,
                    bottom: 0.w,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: 100.r,
                      height: 130.r,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(imageUrl ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
        SizedBox(
          height: 25,
          child: Text(
            name ?? '',
            maxLines: 1,
            style: TextUtils.setTextStyle(
              fontSize: 14.2.sp,
              color: nameColor ??
                  Colors
                      .white, // Use the nameColor if provided, otherwise fallback to the theme's primary color
              engFont: 12.sp,
            ),
          ),
        ),
        Center(
          // Center the row horizontally
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .center, // This aligns the icons to the center if you prefer not to use the Center widget
            children: [
              SizedBox(
                width: 3.w,
              ),
              _buildIconText('assets/football-field.svg', number2),
              SizedBox(
                width: ScreenUtil().setWidth(10.w),
              ),
              _buildIconText('assets/Soccerball.svg', number1),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildIconText(
    String? imgUrl,
    int? number,
  ) {
    IconData? iconData;
    // Map your imgUrl to IconData
    if (imgUrl == 'assets/football-field.svg') {
      iconData = Icons.stadium_outlined; // Example icon, adjust as needed
    } else if (imgUrl == 'assets/Soccerball.svg') {
      iconData = Icons.sports_soccer; // Example icon, adjust as needed
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: Colors.white,
          width: 0.3.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconData != null
              ? Icon(
                  iconData,
                  size: 15.r, // Adjust icon size as needed
                  color: Colors.white,
                )
              : const SizedBox.shrink(),
          SizedBox(width: 2.r),
          Text(
            number != null ? number.toString() : '',
            style: TextUtils.setTextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
