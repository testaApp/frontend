import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/timeFormatter.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';
import '../../styles/social_media.dart';

class TwitterWgt extends StatefulWidget {
  const TwitterWgt({
    super.key,
    required this.feedText,
    required this.author,
    required this.commentsCount,
    required this.likesCount,
    required this.userName,
    required this.userImage,
    this.feedImage,
    required this.textColor, // Add this parameter
    required this.feedTime,
  });

  final String userName;
  final String userImage;
  final String author;
  final String feedTime;
  final String? feedImage;
  final String feedText;
  final int likesCount;
  final int commentsCount;
  final Color textColor;

  @override
  State<TwitterWgt> createState() => _TwitterWgtState();
}

class _TwitterWgtState extends State<TwitterWgt> {
  @override
  Widget build(BuildContext context) {
    final time = formatTime(widget.feedTime);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(2.0.w),
                  child: CircleAvatar(
                    radius: 20.w,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18.w,
                      backgroundColor: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: widget.userImage,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/testa_logo.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.w,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      child: SizedBox(
                        width: 270.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.author == ''
                                  ? widget.userName.substring(1)
                                  : widget.author,
                              style: Author.copyWith(color: widget.textColor),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Icon(
                              Icons.verified_rounded,
                              color: const Color.fromRGBO(251, 208, 1, 1),
                              size: 14.sp,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: IntrinsicWidth(
                                      child: Text(
                                        widget.userName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '• $time',
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const Icon(
                                Icons.more_vert_sharp,
                                color: Colors.grey,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 0, 0, 0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 270.w,
                            child: ExpandableText(
                              linkColor: Colors.blue,
                              widget.feedText.replaceFirst(RegExp(r'^\s+'), ''),
                              maxLines: 8,
                              animationDuration:
                                  const Duration(microseconds: 500),
                              animation: EditableText.debugDeterministicCursor,
                              expandText: 'Show more',
                              textAlign: TextAlign.start,
                              collapseText: 'Show less',
                              style: Post.copyWith(color: widget.textColor),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: widget.feedImage == ''
                                  ? const SizedBox.shrink()
                                  : CachedNetworkImage(
                                      imageUrl: widget.feedImage!,
                                      placeholder: (context, url) {
                                        return Container(
                                          height: 150.h,
                                          color: Colorscontainer.greyShade,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Loading the image',
                                              style: TextUtils.setTextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        );
                                      },
                                      width: 270.w,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(
                                            'assets/testa_logo.png');
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: 270.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                      'https://twitter.com/${widget.userName.substring(1)}',
                                    ));
                                  },
                                  child: const Image(
                                    image: AssetImage(
                                      'assets/twitter_comment.png',
                                    ),
                                    color: Colors.grey,
                                    height: 14,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                      'https://twitter.com/${widget.userName.substring(1)}',
                                    ));
                                  },
                                  child: const Image(
                                    image: AssetImage('assets/retweet.png'),
                                    color: Colors.grey,
                                    height: 18,
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite_outline,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                      'https://twitter.com/${widget.userName.substring(1)}',
                                    ));
                                  },
                                  child: const Image(
                                    image: AssetImage('assets/chart.png'),
                                    color: Colors.grey,
                                    height: 16,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Share.share(
                                        'check out our website https://testa.et');
                                  },
                                  child: const Icon(
                                    Icons.share,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
