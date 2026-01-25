import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../functions/date_conversion.dart';
import '../../constants/text_utils.dart';
import '../../styles/social_media.dart';

class FacebookWgt extends StatefulWidget {
  const FacebookWgt(
      {super.key,
      required this.feedText,
      required this.commentsCount,
      required this.likesCount,
      required this.userName,
      required this.userImage,
      this.feedImage,
      required this.feedTime});
  final String userName;
  final String userImage;
  final String feedTime;
  final String? feedImage;
  final String feedText;
  final int likesCount;
  final int commentsCount;

  @override
  State<FacebookWgt> createState() => _FacebookWgtState();
}

class _FacebookWgtState extends State<FacebookWgt> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    final time = extractTime(widget.feedTime);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Colors.grey[900]?.withOpacity(0.75),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                // margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(14.w, 0, 0, 0),
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  // image: DecorationImage(image: CachedNetworkImageProvider(widget.userImage))
                                  // image: DecorationImage(
                                  //   image: AssetImage('assets/champions.png'),
                                  //   fit: BoxFit.cover
                                  // )
                                ),
                                child: CircleAvatar(
                                  radius: 20.w,
                                  backgroundImage: CachedNetworkImageProvider(
                                    widget.userImage,
                                    errorListener: (error) =>
                                        const Icon(Icons.network_locked),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Text(
                                      widget.userName,
                                      style: facebookAuthor,
                                    ),
                                    SizedBox(
                                      width: 3.w,
                                    ),
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Colors.blue,
                                      size: 14.sp,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(time,
                                        style: TextUtils.setTextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600])),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      '·',
                                      style: TextUtils.setTextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Image.asset(
                                      'assets/world_map.png',
                                      height: 13,
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            size: 20.w,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    // SizedBox(height: 20,),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 12.w, 0),
                      child: ExpandableText(
                        widget.feedText,
                        expandText: 'See more',
                        collapseText: '',
                        linkColor: Colors.grey,
                        linkStyle: const TextStyle(fontSize: 15),
                        animationDuration: const Duration(microseconds: 450),
                        maxLines: 3,
                        style: facebookPost,
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),

                    SizedBox(
                        width: double.maxFinite,
                        child: widget.feedImage != null ||
                                widget.feedImage != ''
                            ? CachedNetworkImage(
                                imageUrl: widget.feedImage!,
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) => Container(
                                      height: 200,
                                      color: Colors.grey,
                                    ),
                                errorWidget: (context, url, error) => Stack(
                                      children: [
                                        Positioned.fill(
                                            child: Image.asset(
                                          'assets/testa_logo.png',
                                          fit: BoxFit.fitWidth,
                                          height: 80.h,
                                        )),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '',
                                                style: TextUtils.setTextStyle(
                                                    backgroundColor:
                                                        Colors.black,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                            : const SizedBox.shrink()),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // makeLike(),
                            Transform.translate(
                              offset: const Offset(-5, 0),
                              // child: makeLove()
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              'assets/likeCount.png',
                              height: 14,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            // Text(widget.likesCount.toString(), style: TextUtils.setTextStyle(fontSize: 13, color: Colors.grey[600]),)
                          ],
                        ),
                        const Expanded(child: SizedBox()),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '',
                              // "${widget.commentsCount} comments",
                              style: TextUtils.setTextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '',
                            // "${widget.commentsCount} share",
                            style: TextUtils.setTextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                        )
                      ],
                    ),

                    const Divider(
                      color: Colors.grey,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  isActive = !isActive;
                                });
                              },
                              child: makeLikeButton(isActive: isActive)),
                          makeCommentButton(),
                          makeShareButton(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget makeLikeButton({isActive}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    // decoration: BoxDecoration(
    //   color: Colors.grey.shade700.withOpacity(0.4) ,
    //   borderRadius: BorderRadius.circular(15.sp)
    // ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/like.png',
            height: 15,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            'Like',
            style: TextUtils.setTextStyle(
                color: isActive ? Colors.blue : Colors.grey, fontSize: 14),
          )
        ],
      ),
    ),
  );
}

Widget makeCommentButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    // decoration: BoxDecoration(
    //   color: Colors.grey.shade700.withOpacity(0.4) ,
    //   borderRadius: BorderRadius.circular(15.sp)
    // ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // ignore: deprecated_member_use
          SvgPicture.asset('assets/facebook_comment.svg',
              height: 16, color: Colors.grey),
          const SizedBox(
            width: 5,
          ),
          Text(
            'Comment',
            style: TextUtils.setTextStyle(color: Colors.grey, fontSize: 14),
          )
        ],
      ),
    ),
  );
}

Widget makeShareButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    //  decoration: BoxDecoration(
    //     color: Colors.grey.shade700.withOpacity(0.4) ,
    //     borderRadius: BorderRadius.circular(15.sp)
    //   ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/tg_share.png',
                height: 18,
                color: Colors.grey,
              )),
          const SizedBox(
            width: 5,
          ),
          Text(
            'Share',
            style: TextUtils.setTextStyle(color: Colors.grey, fontSize: 14),
          )
        ],
      ),
    ),
  );
}
