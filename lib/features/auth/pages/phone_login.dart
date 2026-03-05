import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:blogapp/state/application/auth/auth_bloc.dart';
import 'package:blogapp/state/application/auth/auth_event.dart';
import 'package:blogapp/state/application/auth/auth_state.dart';
import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/auth/pages/country_picker.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final FocusNode _nameTextFieldFocusNode = FocusNode();

  bool isButtonEnabled = false;
  bool isUserTyping = false;

  List<CountryModel> countryList = [];
  CountryModel? selectedCountryData;

  @override
  void initState() {
    super.initState();
    phoneNumberController.addListener(_updateButtonState);
    usernameController.addListener(_updateButtonState);
    _nameTextFieldFocusNode.addListener(_onNameTextFieldFocusChange);
    _loadCountries();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    usernameController.dispose();
    _nameTextFieldFocusNode.dispose();
    super.dispose();
  }

  void _onNameTextFieldFocusChange() {
    setState(() {
      isUserTyping = _nameTextFieldFocusNode.hasFocus;
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = phoneNumberController.text.isNotEmpty &&
          usernameController.text.isNotEmpty;
    });
  }

  Future<void> _loadCountries() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/countrycodes.json');
    final parsed = json.decode(data.toString()).cast<Map<String, dynamic>>();
    setState(() {
      countryList =
          parsed.map<CountryModel>((json) => CountryModel.fromJson(json)).toList();
      selectedCountryData = countryList.isNotEmpty ? countryList[0] : null;
    });
  }

  void _onCountryChanged(String? name, String? dialCode, String? flag) {
    final match = countryList.firstWhere(
      (c) => c.name == name && c.dialCode == dialCode,
      orElse: () => selectedCountryData ?? countryList.first,
    );
    setState(() {
      selectedCountryData = match;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[400]),
    );
  }

  void _submit() {
    final phoneNumber =
        "${selectedCountryData?.dialCode}${phoneNumberController.text}";

    context.read<AuthBloc>().add(RequestOtpEvent(phoneNumber: phoneNumber));
    context.pushNamed(RouteNames.passcode, queryParameters: {
      'phoneNumber': phoneNumber,
      'name': usernameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined,
              size: 18.sp, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.requestStatus == RequestStatus.internalServerError) {
            _showError('Server error. Try again.');
          } else if (state.requestStatus == RequestStatus.numberNotFound) {
            _showError('Phone number not found.');
          } else if (state.requestStatus == RequestStatus.failed) {
            _showError(DemoLocalizations.networkProblem);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),
                Text(
                  DemoLocalizations.phoneNumber,
                  style: TextUtils.setTextStyle(
                    fontSize: 20.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  DemoLocalizations.enter_your_phone_number,
                  style: TextUtils.setTextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildPhoneInput(),
                SizedBox(height: 20.h),
                _buildNameInput(),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      DemoLocalizations.next,
                      style: TextUtils.setTextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        children: [
          CountryPicker(
            countryList: countryList,
            selectedCountryData: selectedCountryData,
            callBackFunction: _onCountryChanged,
            headerBackgroundColor: Colors.transparent,
            headerTextColor: Colors.white,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              controller: phoneNumberController,
              style: TextUtils.setTextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: DemoLocalizations.enter_phone_number,
                border: InputBorder.none,
                hintStyle: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUserTyping
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: usernameController,
              focusNode: _nameTextFieldFocusNode,
              style: TextUtils.setTextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: DemoLocalizations.whoToCall,
                border: InputBorder.none,
                hintStyle: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
