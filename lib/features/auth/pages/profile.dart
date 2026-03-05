import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';

import 'package:blogapp/state/application/auth/auth_event.dart';
import 'package:blogapp/state/application/auth/auth_state.dart';
import 'package:blogapp/features/auth/services/store_info.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/core/storage/delete_hive_box.dart';
import 'package:blogapp/core/notifiers/username_notifier.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/state/application/auth/auth_bloc.dart';
import 'package:blogapp/Homepage.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final Uint8List? imageData;

  const ProfilePage({
    super.key,
    required this.name,
    required this.phoneNumber,
    this.imageData,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  Uint8List? _cachedImageData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isChangingPhone = false;
  String? _newPhoneNumber;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _setupAnimations();
    _loadCachedImage();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _loadCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedImage = prefs.getString('cachedImageData');
    if (encodedImage != null) {
      setState(() {
        _cachedImageData = base64Decode(encodedImage);
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      userNameNotifier.value = null;
      final statusCode = await _performLogout();

      if (statusCode == 200) {
        await _clearUserData();
        if (mounted) context.pushReplacement('/videointro');
      } else {
        _showErrorSnackbar('Logout failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Error during logout: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<int> _performLogout() async {
    final url = BaseUrl().url;
    try {
      final response = await http.post(
        Uri.parse('$url/api/authentication/loggout'),
        headers: await buildAuthHeaders(),
        body: json.encode({'logout': true}),
      );
      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedImageData');
    await deleteHiveBox<int>('team');
    await signOutToAnonymous();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
        requestFullMetadata: true,
      );

      if (image != null && mounted) {
        await _handleImageUpload(image);
      }
    } catch (e) {
      print('Image picker error: $e');
      if (mounted) {
        _showErrorSnackbar('Failed to pick image');
      }
    }
  }

  Future<void> _handleImageUpload(XFile image) async {
    try {
      setState(() => _isLoading = true);

      final bytes = await image.readAsBytes();
      final String fileExtension = image.path.split('.').last.toLowerCase();
      final String mimeType =
          fileExtension == 'png' ? 'image/png' : 'image/jpeg';

      // Cache image data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String encodedImage = base64Encode(bytes);
      await prefs.setString('profileImage', encodedImage);
      await prefs.setString('cachedImageData', encodedImage);

      // Update UI state
      setState(() {
        _cachedImageData = bytes;
      });

      // Upload to server
      String url = BaseUrl().url;
      var uri = Uri.parse('$url/api/user/uploadImage');
      var request = http.MultipartRequest('POST', uri);

      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'profile_image.$fileExtension',
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Set headers
      final token = await getFirebaseIdToken();
      request.headers.addAll({
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Upload request timed out');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        _showErrorSnackbar('Session expired. Please log in again.');
        return;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          _showSuccessSnackbar('Profile picture updated successfully');
        }
      } else {
        String errorMessage = 'Failed to update profile picture';
        try {
          if (response.headers['content-type']?.contains('application/json') ==
              true) {
            final errorBody = json.decode(response.body);
            errorMessage = errorBody['message'] ?? errorMessage;
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        if (mounted) {
          _showErrorSnackbar(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      print('Upload error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackbar(
          e is TimeoutException
              ? 'Upload timed out. Please try again.'
              : 'Error updating profile picture',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_phoneController.text != widget.phoneNumber && !_isChangingPhone) {
      _showErrorSnackbar(DemoLocalizations.verify_phone_first);
      return;
    }

    setState(() => _isLoading = true);

    try {
      setState(() => _isEditing = false);
      _showSuccessSnackbar(DemoLocalizations.profile_update_success);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackbar('${DemoLocalizations.update_profile_error}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _initiatePhoneChange() async {
    final newPhone = _phoneController.text;
    if (newPhone == widget.phoneNumber) {
      _showErrorSnackbar('Please enter a different phone number');
      return;
    }

    setState(() {
      _isChangingPhone = true;
      _newPhoneNumber = newPhone;
    });

    context.read<AuthBloc>().add(
          RequestOtpEvent(phoneNumber: newPhone),
        );
  }

  Future<void> _showVerificationDialog() async {
    final TextEditingController otpController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(DemoLocalizations.verify_phone_first),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${DemoLocalizations.enterOTP} $_newPhoneNumber'),
              SizedBox(height: 16.h),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '0000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isChangingPhone = false;
                  _phoneController.text = widget.phoneNumber;
                });
              },
              child: Text(DemoLocalizations.cancel),
            ),
            TextButton(
              onPressed: () => _verifyOtp(otpController.text),
              child: Text(DemoLocalizations.verify),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyOtp(String otp) async {
    if (_newPhoneNumber == null) return;

    try {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              otp: otp,
              phoneNumber: _newPhoneNumber!,
              name: _nameController.text,
              deviceInfo: null, // Add device info if needed
            ),
          );
    } catch (e) {
      _showErrorSnackbar('Error during verification: $e');
    }
  }

  Future<void> _updatePhoneNumber(String newPhone) async {
    // Add your API call here to update the phone number
    // Example:
    // await updateUserPhone(newPhone);

    // Update stored phone number
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', newPhone);
    await storeInformation(key: 'phoneNumber', value: newPhone);
    phonenumberNotifier.value = newPhone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle Request Status
        if (state.requestStatus == RequestStatus.success) {
          _showVerificationDialog();
        } else if (state.requestStatus == RequestStatus.failed) {
          _handleRequestError('Request failed');
        } else if (state.requestStatus == RequestStatus.internalServerError) {
          _handleRequestError('Internal server error');
        } else if (state.requestStatus == RequestStatus.numberNotFound) {
          _handleRequestError('Phone number not found');
        }

        // Handle Verification Status
        if (state.verificationStatus == VerificationStatus.success) {
          _handleVerificationSuccess();
        } else if (state.verificationStatus ==
            VerificationStatus.networkFailure) {
          _handleVerificationError('Network error');
        } else if (state.verificationStatus ==
            VerificationStatus.internalServerError) {
          _handleVerificationError('Server error');
        } else if (state.verificationStatus == VerificationStatus.otpError) {
          _handleVerificationError('Invalid OTP');
        } else if (state.verificationStatus == VerificationStatus.otpExpired) {
          _handleVerificationError('OTP expired');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            DemoLocalizations.profile,
            style: TextUtils.setTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                bool isProcessing = state.requestStatus ==
                        RequestStatus.requesting ||
                    state.verificationStatus == VerificationStatus.requested;

                return IconButton(
                  icon: isProcessing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colorscontainer.greenColor,
                          ),
                        )
                      : Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: isProcessing
                      ? null
                      : () => setState(() => _isEditing = !_isEditing),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      _buildProfileImage(),
                      if (_isEditing)
                        TextButton(
                          onPressed: _pickImage,
                          child: Text(DemoLocalizations.change_photo),
                        ),
                      SizedBox(height: 30.h),
                      _buildInfoCard(state),
                      SizedBox(height: 30.h),
                      if (_isEditing)
                        _buildSaveButton(state)
                      else
                        _buildLogoutButton(state),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'profile_image',
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: _cachedImageData != null
                  ? MemoryImage(_cachedImageData!)
                  : const AssetImage('assets/playershimmer.png')
                      as ImageProvider,
            ),
          ),
        ),
        if (_isLoading)
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(AuthState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoField(
            icon: Icons.phone,
            label: DemoLocalizations.phoneNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            state: state,
          ),
          SizedBox(height: 15.h),
          _buildInfoField(
            icon: Icons.person,
            label: DemoLocalizations.name,
            controller: _nameController,
            state: state,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required AuthState state,
    TextInputType? keyboardType,
  }) {
    bool isPhone = label == DemoLocalizations.phoneNumber;
    bool isProcessing = state.requestStatus == RequestStatus.requesting ||
        state.verificationStatus == VerificationStatus.requested;

    return Row(
      children: [
        Icon(icon, color: Colorscontainer.greenColor, size: 24.w),
        SizedBox(width: 15.w),
        Expanded(
          child: _isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        enabled: !isProcessing,
                        decoration: InputDecoration(
                          labelText: label,
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    if (isPhone && _isEditing)
                      TextButton(
                        onPressed: isProcessing ? null : _initiatePhoneChange,
                        child: Text(isProcessing
                            ? DemoLocalizations.verifying
                            : DemoLocalizations.verify),
                      ),
                  ],
                )
              : Text(
                  controller.text,
                  style: TextUtils.setTextStyle(fontSize: 16.sp),
                ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colorscontainer.greenColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                DemoLocalizations.logout,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSaveButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colorscontainer.greenColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                DemoLocalizations.save_changes,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleRequestError(String message) {
    setState(() => _isChangingPhone = false);
    _showErrorSnackbar(message);
  }

  Future<void> _handleVerificationSuccess() async {
    if (_newPhoneNumber != null) {
      await _updatePhoneNumber(_newPhoneNumber!);

      if (mounted) {
        Navigator.pop(context); // Close verification dialog
        setState(() {
          _isChangingPhone = false;
        });
        _showSuccessSnackbar('Phone number updated successfully');
      }
    }
  }

  void _handleVerificationError(String message) {
    if (mounted) {
      Navigator.pop(context); // Close verification dialog
      setState(() {
        _isChangingPhone = false;
        _phoneController.text = widget.phoneNumber;
      });
      _showErrorSnackbar('Verification failed: $message');
    }
  }
}
