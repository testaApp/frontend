import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/services/sync_service.dart';
import 'package:blogapp/services/following_storage_service.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/features/auth/services/social_auth_service.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/auth/pages/phone_login.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  String _loadingLabel = '';

  Future<void> _handleSocialLogin(
      Future<UserCredential> Function() signIn, String label) async {
    setState(() {
      _isLoading = true;
      _loadingLabel = label;
    });

    try {
      final credential = await signIn();
      final user = credential.user;

      if (user != null) {
        final name =
            user.displayName ?? user.email?.split('@').first ?? 'User';
        await cacheUserInfo(name: name);

        final storageService = FollowingStorageService();
        await storageService.init();
        await syncFollowingDataAfterLogin(storageService: storageService);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = '';
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(context),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            'Testa',
            style: TextUtils.setTextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            DemoLocalizations.register,
            style: TextUtils.setTextStyle(
              fontSize: 22.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Choose a sign up method',
            style: TextUtils.setTextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 20.h),
          _LoginButton(
            icon: Icons.phone_android,
            label: 'Use phone number',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
              );
            },
          ),
          _LoginButton(
            icon: FontAwesomeIcons.google,
            label: 'Continue with Google',
            onTap: () => _handleSocialLogin(
              SocialAuthService.signInWithGoogle,
              'Google',
            ),
          ),
          _LoginButton(
            icon: FontAwesomeIcons.facebook,
            label: 'Continue with Facebook',
            onTap: () => _handleSocialLogin(
              SocialAuthService.signInWithFacebook,
              'Facebook',
            ),
          ),
          _LoginButton(
            icon: FontAwesomeIcons.apple,
            label: 'Continue with Apple',
            onTap: () => _handleSocialLogin(
              SocialAuthService.signInWithApple,
              'Apple',
            ),
          ),
          _LoginButton(
            icon: FontAwesomeIcons.xTwitter,
            label: 'Continue with X',
            onTap: () => _handleSocialLogin(
              SocialAuthService.signInWithTwitter,
              'X',
            ),
          ),
          const Spacer(),
          Text(
            'By continuing, you agree to our Terms and Privacy Policy.',
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              color: Colors.white54,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colorscontainer.greenColor,
            ),
            SizedBox(height: 12.h),
            Text(
              'Signing in $_loadingLabel...',
              style: TextUtils.setTextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20.sp, color: Colors.black),
          label: Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }
}
