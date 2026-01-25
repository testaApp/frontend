import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../components/timeFormatter.dart';
import '../../constants/text_utils.dart';

class Instagram extends StatefulWidget {
  final String username;
  final int likes;
  final String time;
  final String profilePicture;
  final String image;
  final String? feedText;

  const Instagram({
    super.key,
    required this.username,
    required this.likes,
    required this.time,
    this.profilePicture = '',
    required this.image,
    this.feedText = '',
  });

  @override
  _InstagramState createState() => _InstagramState();
}

class _InstagramState extends State<Instagram> {
  bool isLiked = false;
  bool displayHeart = false;

  @override
  Widget build(BuildContext context) {
    final time = formatTime(widget.time);
    const whiteOffColor = Color(0xFFEFEFEF); // Define the white off-color

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
            height: 37.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    widget.profilePicture == ''
                        ? CircleAvatar(
                            radius: 15.0.r,
                            backgroundImage:
                                const AssetImage('assets/champions.png'),
                          )
                        : CircleAvatar(
                            radius: 15.0.r,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.profilePicture),
                          ),
                    const SizedBox(width: 6.0),
                    Row(
                      children: [
                        Text(widget.username,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextUtils.setTextStyle(
                                fontFamily: 'Sans_bold',
                                fontSize: 14.sp,
                                color: whiteOffColor)), // Use white off-color
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.verified_rounded,
                          color: const Color.fromARGB(255, 63, 159, 238),
                          size: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20.w,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                isLiked = !isLiked;
                displayHeart = true;
              });
              Future.delayed(const Duration(milliseconds: 750), () {
                setState(() {
                  displayHeart = false;
                });
              });
            },
            child: displayHeart == true
                ? Stack(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CachedNetworkImage(
                          imageUrl: widget.image,
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 120.h,
                            color: Colors.grey,
                            child: const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 120.h,
                            color: Colors.grey,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text('Network error'),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 80.h,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(FontAwesomeIcons.solidHeart,
                                color: whiteOffColor,
                                size: 60.0.h), // Use white off-color
                          )
                        ],
                      ),
                    ],
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: widget.image,
                      fit: BoxFit.fitWidth,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 120.h,
                        color: Colors.grey,
                        child: const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 120.h,
                        color: Colors.grey,
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text('Network error'),
                        ),
                      ),
                    ),
                  ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    isLiked == true
                        ? const Icon(Icons.favorite_outlined,
                            color: Colors.red, size: 25.0)
                        : Icon(FontAwesomeIcons.heart,
                            size: 18.h,
                            color: whiteOffColor), // Use white off-color
                    const SizedBox(width: 15.0),
                    SvgPicture.asset(
                      'assets/insta_comment.svg',
                      height: 18.h,
                      color: whiteOffColor, // Use white off-color
                    ),
                    const SizedBox(width: 15.0),
                    SvgPicture.asset('assets/insta_share.svg',
                        height: 18.h,
                        color: whiteOffColor), // Use white off-color
                  ],
                ),
                Icon(
                  FontAwesomeIcons.bookmark,
                  size: 18.h,
                  color: whiteOffColor, // Use white off-color
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.w),
            child: Text('${widget.likes} likes',
                style: TextUtils.setTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0.sp,
                    color: whiteOffColor)), // Use white off-color
          ),
          const SizedBox(
            height: 7,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.w),
            child: ExpandableText(
              '${widget.username} ${widget.feedText ?? ""}',
              expandText: 'more',
              maxLines: 2,
              style:
                  const TextStyle(color: whiteOffColor), // Use white off-color
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 5.0),
            child: Text('$time ago',
                style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
