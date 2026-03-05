import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/shared/constants/colors.dart';

class ImageSelector extends StatefulWidget {
  final String? verificationStatus;
  final Uint8List? imageData;
  final Uint8List? cachedImageData;
  final Future<void> Function() pickImage;
  const ImageSelector(
      {super.key,
      required this.verificationStatus,
      required this.imageData,
      required this.cachedImageData,
      required this.pickImage});

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  Future<void> _uploadImageToServer(String filePath) async {
    var uri =
        Uri.parse('your_server_endpoint'); // Replace with your server endpoint
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', filePath));
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(78.h),
              child: Container(
                width: 78.h,
                height: 78.h,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: Colorscontainer.greenColor),
                    borderRadius: BorderRadius.circular(78.h)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(77.h),
                  child: SizedBox(
                    width: 77.h,
                    height: 77.h,
                    child: Stack(
                      children: [
                        widget.imageData != null
                            ? ClipOval(
                                child: Image.memory(
                                  widget.imageData!,
                                  fit: BoxFit.cover,
                                  width: 76.h,
                                  height: 76.h,
                                ),
                              )
                            : widget.cachedImageData != null
                                ? ClipOval(
                                    child: Image.memory(
                                      widget.cachedImageData!,
                                      fit: BoxFit.cover,
                                      width: 76.h,
                                      height: 76.h,
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      color: Colors.blueGrey,
                                      child: Icon(Icons.person, size: 79.h),
                                    ),
                                  ),
                        //
                        Column(
                          children: [
                            const Expanded(
                                child: SizedBox(
                              width: 2,
                            )),
                            widget.verificationStatus == null
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: widget.verificationStatus != null
                                        ? () async {
                                            await widget.pickImage();
                                          }
                                        : () {
                                            context.pushNamed(RouteNames.login);
                                          },
                                    child: Container(
                                        color: Colors.grey.withOpacity(0.8),
                                        width: double.maxFinite,
                                        child: Icon(
                                          Icons.photo_camera_rounded,
                                          color: Colors.white,
                                          size: 18.sp,
                                        )),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
