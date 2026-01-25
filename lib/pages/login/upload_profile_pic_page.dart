import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../Homepage.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/text_utils.dart';
import '../../localization/demo_localization.dart';

class UploadProfilePicPage extends StatelessWidget {
  const UploadProfilePicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    size: 60.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  DemoLocalizations.addProfilePicture,
                  style: TextUtils.setTextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  DemoLocalizations.chooseProfilePicture,
                  textAlign: TextAlign.center,
                  style: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        DemoLocalizations.skip,
                        style: TextUtils.setTextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickAndUploadImage(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        DemoLocalizations.choosePhoto,
                        style: TextUtils.setTextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
        requestFullMetadata: true,
      );

      if (image != null) {
        print('Selected image path: ${image.path}');
        print('Selected image name: ${image.name}');
        if (context.mounted) {
          await _handleImageUpload(context, image);
        }
      }
    } catch (e) {
      print('Image picker error: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to pick image');
      }
    }
  }

  Future<void> _handleImageUpload(BuildContext context, XFile image) async {
    try {
      _showLoadingDialog(context);

      final bytes = await image.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      // Get file extension and validate
      final String fileExtension = image.path.split('.').last.toLowerCase();
      print('File extension: $fileExtension');

      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg';
      if (fileExtension == 'png') {
        mimeType = 'image/png';
      }
      print('MIME type: $mimeType');

      // Upload to server
      String url = BaseUrl().url;
      var uri = Uri.parse('$url/api/user/uploadImage');
      print('Uploading to: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Add the file with explicit content type
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'profile_image.$fileExtension',
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Get and verify token
      String token = await getAccessToken();
      print('Token being used: $token'); // Debug token

      // Set headers
      request.headers.addAll({
        'accesstoken': token,
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      print('Sending request with headers: ${request.headers}');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Upload request timed out');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      if (response.statusCode == 401) {
        // Handle unauthorized error specifically
        _showErrorMessage(context, 'Session expired. Please log in again.');
        // Optionally, redirect to login page
        // context.goNamed(RouteNames.login);
        return;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Cache image locally after successful upload
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', base64Encode(bytes));
        await prefs.setString('cachedImageData', base64Encode(bytes));

        _showSuccessMessage(context, DemoLocalizations.profilePictureUpdated);

        // Modified navigation approach
        if (context.mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          });
        }
      } else {
        String errorMessage = DemoLocalizations.uploadImageFailed;
        try {
          if (response.headers['content-type']?.contains('application/json') ==
              true) {
            final errorBody = json.decode(response.body);
            errorMessage = errorBody['message'] ?? errorMessage;
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        _showErrorMessage(context, errorMessage);
      }
    } catch (e, stackTrace) {
      print('Upload error: $e');
      print('Stack trace: $stackTrace');
      if (!context.mounted) return;
      Navigator.pop(context);
      _showErrorMessage(
          context,
          e is TimeoutException
              ? 'Upload timed out. Please try again.'
              : DemoLocalizations.uploadImageError);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
