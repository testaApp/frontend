import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blogapp/state/application/auth/auth_bloc.dart';
import 'package:blogapp/state/application/auth/auth_event.dart';
import 'package:blogapp/state/application/auth/auth_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/features/auth/services/store_info.dart';
import 'package:blogapp/core/notifiers/username_notifier.dart';
import 'package:blogapp/services/following_storage_service.dart';
import 'package:blogapp/services/sync_service.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/auth/pages/upload_profile_pic_page.dart';

class PassCode extends StatefulWidget {
  final String phoneNumber;
  final String name;
  const PassCode({super.key, required this.phoneNumber, required this.name});

  @override
  _PassCodeState createState() => _PassCodeState();
}

class _PassCodeState extends State<PassCode>
    with SingleTickerProviderStateMixin {
  List<TextEditingController> textControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool filled = false;
  final List<GlobalKey<FormState>> _formKeys =
      List.generate(4, (index) => GlobalKey<FormState>());

  int _countdown = 60;
  Timer? _timer;
  bool _isCountdownFinished = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void dispose() {
    for (var controller in textControllers) {
      controller.removeListener(updateFilledStatus);
      controller.dispose();
    }
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showScaffoldMessage(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        style: TextUtils.setTextStyle(),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red[400],
    ));
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    for (var controller in textControllers) {
      controller.addListener(updateFilledStatus);
    }
    startCountdown();
  }

  void startCountdown() {
    setState(() {
      _countdown = 60;
      _isCountdownFinished = false;
    });

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isCountdownFinished = true;
          timer.cancel();
          // Show a snackbar when timer ends
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DemoLocalizations.canRequestNewCode,
                style: TextUtils.setTextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  void updateFilledStatus() {
    bool allFieldsFilled = true;
    for (var controller in textControllers) {
      if (controller.text.isEmpty) {
        allFieldsFilled = false;
        break;
      }
    }
    setState(() {
      filled = allFieldsFilled;
    });
  }

  String sliceDigitsAfterColon(String inputString) {
    final parts = inputString.split(':');
    if (parts.length > 1) {
      final digits = parts[1].trim();
      if (digits.length >= 4) {
        return digits.substring(0, 4);
      }
    }
    return '';
  }

  void resendOtp() {
    setState(() {
      _countdown = 60;
      _isCountdownFinished = false;
    });
    startCountdown();
    context
        .read<AuthBloc>()
        .add(RequestOtpEvent(phoneNumber: widget.phoneNumber));
  }

  Future<void> verifyOtp() async {
    String otp = '';
    for (var controller in textControllers) {
      otp = otp + controller.text;
    }

    if (otp.length != 4) {
      _showErrorMessage(DemoLocalizations.invalidOTP);
      return;
    }

    // Show loading indicator
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

    try {
      context.read<AuthBloc>().add(VerifyOtpEvent(
            otp: otp,
            phoneNumber: widget.phoneNumber,
            name: widget.name,
          ));
      // Clear the OTP fields after submission
      for (var controller in textControllers) {
        controller.clear();
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading indicator
      _showErrorMessage(DemoLocalizations.serverError);
    }
  }

  bool areAllFieldsFilled(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _showErrorMessage(String message) {
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

  Future<void> storeUserInfo(
      {required String phoneNumber, required String name}) async {
    // Store in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('name', name);

    // Update username notifier
    userNameNotifier.value = name;
    phonenumberNotifier.value = phoneNumber;

    // Store user information using secure storage
    await storeInformation(key: 'phoneNumber', value: phoneNumber);
    await storeInformation(key: 'name', value: name);
  }

  @override
  Widget build(BuildContext context) {
    bool filled = areAllFieldsFilled(textControllers);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 18.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          switch (state.verificationStatus) {
            case VerificationStatus.success:
            case VerificationStatus.found:
              // First store user info
              storeUserInfo(
                phoneNumber: widget.phoneNumber,
                name: widget.name,
              );

              final storageService = FollowingStorageService();
              storageService.init().then((_) {
                syncFollowingDataAfterLogin(storageService: storageService);
              });

              // Only show image upload dialog if we're not already showing it
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Dismiss loading indicator
              }

              // Use Future.microtask to avoid navigation conflicts
              Future.microtask(() {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadProfilePicPage(),
                    ),
                  );
                }
              });
              break;

            case VerificationStatus.otpError:
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Dismiss loading indicator
              }
              _showErrorMessage(DemoLocalizations.passwordIncorrect);
              break;

            case VerificationStatus.otpExpired:
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Dismiss loading indicator
              }
              _showErrorMessage(DemoLocalizations.otpExpired);
              break;

            case VerificationStatus.networkFailure:
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Dismiss loading indicator
              }
              _showErrorMessage(DemoLocalizations.networkProblem);
              break;

            case VerificationStatus.internalServerError:
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Dismiss loading indicator
              }
              _showErrorMessage(DemoLocalizations.error);
              break;

            default:
              break;
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    DemoLocalizations.enterCode,
                    style: TextUtils.setTextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${DemoLocalizations.enterOTP} ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildPinInputFields(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: _buildNumberPad(),
                    ),
                  ),
                  _buildActionButtons(filled),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => _buildPinField(textControllers[index], _formKeys[index]),
      ),
    );
  }

  Widget _buildPinField(
      TextEditingController controller, GlobalKey<FormState> formKey) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          controller.text,
          style: TextUtils.setTextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 9) return const SizedBox();
        if (index == 10) return _buildNumberKey('0');
        if (index == 11) return _buildBackspaceKey();
        return _buildNumberKey('${index + 1}');
      },
    );
  }

  Widget _buildNumberKey(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          for (var controller in textControllers) {
            if (controller.text.isEmpty) {
              controller.text = number;
              break;
            }
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextUtils.setTextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          for (var controller in textControllers.reversed) {
            if (controller.text.isNotEmpty) {
              controller.clear();
              break;
            }
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.backspace_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool filled) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isLoading =
            state.verificationStatus == VerificationStatus.requested;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: (filled && !isLoading) ? verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        DemoLocalizations.next,
                        style: TextUtils.setTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            _isCountdownFinished
                ? TextButton.icon(
                    onPressed: resendOtp,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      DemoLocalizations.tryAgain,
                      style: TextUtils.setTextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18.sp,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${DemoLocalizations.resendCodeIn} $_countdown ${DemoLocalizations.seconds}',
                        style: TextUtils.setTextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}
