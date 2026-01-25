import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../styles/social_media.dart';

class ClickableLinkText extends StatelessWidget {
  final String textWithLink;
  final String previewImage;
  final String feedImage;
  const ClickableLinkText(
      {super.key,
      required this.textWithLink,
      required this.previewImage,
      required this.feedImage});

  @override
  Widget build(BuildContext context) {
    final linkRegExp = RegExp(r'https?://\S+');

    // Find the first link in the input text
    Match? match = linkRegExp.firstMatch(textWithLink);

    // If a link is found, wrap it in a GestureDetector
    if (match != null) {
      final linkStart = match.start;
      final linkEnd = match.end;

      return GestureDetector(
        onTap: () {
          launchUrl(Uri.parse(match.group(0) ?? ''));
        },
        child: Column(
          children: [
            Text(
                textWithLink.substring(
                  0,
                  linkStart,
                ),
                style: Post),
            GestureDetector(
                child: Text(
                  match.group(0) ?? '',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () {
                  launchUrl(Uri.parse(match.group(0) ?? ''));
                }),
            const SizedBox(
              height: 7,
            ),
            modifyString(textWithLink.substring(linkEnd)) != ''
                ? Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(color: Colors.blue, width: 3))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        children: [
                          Text(modifyString(textWithLink.substring(linkEnd)),
                              style: Post),

                          previewImage != ''
                              ? CachedNetworkImage(
                                  placeholder: (context, url) {
                                    return Container(
                                      color: Colors.grey,
                                    );
                                  },
                                  imageUrl: previewImage,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 50.h,
                                    color: Colorscontainer.greyShade,
                                  ),
                                )
                              : const SizedBox.shrink()
                          // LinkPreviewGenerator(
                          // bodyMaxLines: 0,
                          // link:  match.group(0) ?? "",
                          // linkPreviewStyle: LinkPreviewStyle.large,
                          // showGraphic: true,
                          // showBody: false,
                          // showTitle: false,
                          // boxShadow: null,2
                          // )
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      );
    }

    // If no link is found, simply display the text
    return Text(
      textWithLink,
      style: Post,
    );
  }
}

String modifyString(String input) {
  final lines = input.split('\n');
  final modifiedLines = <String>[];

  bool contentStarted = false;

  for (var line in lines) {
    if (!contentStarted) {
      line = line.trim();
      if (line.isNotEmpty) {
        contentStarted = true;
      }
    }

    if (contentStarted) {
      final trimmedLine = line.trimLeft();
      if (trimmedLine.startsWith('/n')) {
        modifiedLines.add(trimmedLine.substring(2));
      } else {
        modifiedLines.add(line);
      }
    }
  }

  return modifiedLines.join('\n');
}
