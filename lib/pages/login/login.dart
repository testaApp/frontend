import 'dart:async';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_event.dart';
import '../../application/auth/auth_state.dart';
import '../../components/routenames.dart';
import '../../localization/demo_localization.dart';
import '../constants/text_utils.dart';
import 'country_picker.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();

  static void requestOtp(BuildContext context, String phoneNumber) {
    context.read<AuthBloc>().add(RequestOtpEvent(phoneNumber: phoneNumber));
  }
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isButtonEnabled = false;
  bool isUserTyping = false;
  List<CountryModel> countryList = [];
  CountryModel? selectedCountryData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard on app start/restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    phoneNumberController.addListener(enableButton);
    usernameController.addListener(enableButton);
    _nameTextFieldFocusNode.addListener(_onNameTextFieldFocusChange);
    initializeCountryData();
  }

  List<CountryModel> parseJson(String response) {
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed
        .map<CountryModel>(
          (json) => CountryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList() as List<CountryModel>;
  }

  void changeSelectedCountry(newValue) {
    setState(() {
      selectedCountryData = newValue!;
    });
  }

  Future<void> initializeCountryData() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/countrycodes.json');
    setState(() {
      countryList = parseJson(data);
      selectedCountryData = countryList[0];
    });
  }

  void _onNameTextFieldFocusChange() {
    setState(() {
      isUserTyping = _nameTextFieldFocusNode.hasFocus;
    });
  }

  void enableButton() {
    setState(() {
      isButtonEnabled = phoneNumberController.text.isNotEmpty &&
          usernameController.text.isNotEmpty;
    });
  }

  void _showScaffoldMessage(content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red[400],
    ));
  }

  void _callBackFunction(String name, String dialCode, String flag) {
    // place your code
  }

  final FocusNode _nameTextFieldFocusNode = FocusNode();

  @override
  void dispose() {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    phoneNumberController.dispose();
    usernameController.dispose();
    _nameTextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          handleAuthState(state, context);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  _buildLogo(),
                  SizedBox(height: 40.h),
                  _buildWelcomeText(),
                  SizedBox(height: 40.h),
                  _buildPhoneInput(),
                  SizedBox(height: 20.h),
                  _buildNameInput(),
                  SizedBox(height: 40.h),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/testa_appbar.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Text(
          DemoLocalizations.register,
          textAlign: TextAlign.center,
          style: TextUtils.setTextStyle(
            fontSize: 32.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
        child: Row(
          children: [
            CountryPicker(
              countryList: countryList,
              selectedCountryData: selectedCountryData,
              callBackFunction: _callBackFunction,
              headerBackgroundColor: Colors.transparent,
              headerTextColor: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: phoneNumberController,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: DemoLocalizations.phoneNumber,
                  border: InputBorder.none,
                  hintStyle: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUserTyping
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: DemoLocalizations.whoToCall,
                  border: InputBorder.none,
                  hintStyle: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        child: SizedBox(
          width: double.infinity,
          height: 40.h,
          child: ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    String phoneNumber =
                        "${selectedCountryData?.dialCode}${phoneNumberController.text}";
                    context
                        .read<AuthBloc>()
                        .add(RequestOtpEvent(phoneNumber: phoneNumber));

                    // Navigate to the next page immediately
                    context.pushNamed(RouteNames.passcode, queryParameters: {
                      'phoneNumber': phoneNumber,
                      'name': usernameController.text
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
              foregroundColor: isButtonEnabled
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              DemoLocalizations.next,
              style: TextUtils.setTextStyle(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleAuthState(AuthState state, BuildContext context) {
    print(state.requestStatus);
    if (state.requestStatus == RequestStatus.success) {
      String phoneNumber =
          "${selectedCountryData?.dialCode}${phoneNumberController.text}";

      context.pushNamed(RouteNames.passcode, queryParameters: {
        'phoneNumber': phoneNumber,
        'name': usernameController.text
      });
    } else if (state.requestStatus == RequestStatus.internalServerError) {
      _showScaffoldMessage(const Text('Internal Server Error'));
    } else if (state.requestStatus == RequestStatus.numberNotFound) {
      _showScaffoldMessage(const Text('Phone number not correct'));
    } else if (state.requestStatus == RequestStatus.failed) {
      _showScaffoldMessage(Text(DemoLocalizations.networkProblem));
    }
  }
}
