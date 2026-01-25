import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../functions/date_conversion.dart';
import '../../constants/text_utils.dart';
import '../../styles/social_media.dart';
import 'clickable_txt.dart';

class TelegramWgt extends StatefulWidget {
  const TelegramWgt(
      {super.key,
      required this.feedText,
      required this.previewImage,
      required this.author,
      required this.commentsCount,
      required this.likesCount,
      required this.userName,
      required this.userImage,
      this.feedImage,
      required this.feedTime});
  final String userName;
  final String userImage;
  final String author;
  final String feedTime;
  final String? feedImage;
  final String feedText;
  final int likesCount;
  final int commentsCount;
  final String previewImage;

  @override
  State<TelegramWgt> createState() => _TelegramWgtState();
}

class _TelegramWgtState extends State<TelegramWgt> {
  String? profilePicture;
  String? timeLineImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final time = extractTime(widget.feedTime);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(2.0.w),
                    child: CircleAvatar(
                      radius: 15.w,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.userImage,
                        errorListener: (error) => CircleAvatar(
                          radius: 15.w,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: const Color.fromARGB(255, 66, 63, 63)
                            .withOpacity(0.8),
                        padding: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 10.w),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 3),
                              child: SizedBox(
                                width: 270.w,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final url =
                                            'https://t.me/${widget.userName.substring(1)}';
                                        if (await canLaunchUrl(url as Uri)) {
                                          await canLaunchUrl(url as Uri);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        widget.author == ''
                                            ? '@${widget.userName.substring(1)}'
                                            : widget.author,
                                        style: telegramAuthor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 262.w,
                                    child: ClickableLinkText(
                                      textWithLink: widget.feedText,
                                      previewImage: widget.previewImage,
                                      feedImage: widget.feedImage ?? '',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: widget.feedImage == null
                                          ? const SizedBox.shrink()
                                          : InkWell(
                                              onTap: () async {
                                                final url =
                                                    'https://t.me/${widget.feedImage}';
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl: widget.feedImage!,
                                                width: 270.w,
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Image.asset(
                                                      'assets/testa_logo.png');
                                                },
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width: 260.w,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        time,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextUtils.setTextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        Share.share('check out our website https://testa.et');
                      },
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CircleAvatar(
                          radius: 13.w,
                          backgroundColor:
                              const Color.fromARGB(255, 66, 63, 63),
                          child: Padding(
                            padding: EdgeInsets.all(5.w),
                            child: Image.asset(
                              'assets/tg_share.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
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
