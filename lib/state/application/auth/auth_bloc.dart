import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/features/onboarding/pages/device_info.dart';
import 'package:blogapp/features/auth/services/getDeviceInfo.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    on<AuthEvent>((event, emit) {});
    on<RequestOtpEvent>(_handleRequestOtp);
    on<VerifyOtpEvent>(_handleVerifyOtp);
  }
  String url = BaseUrl().url;
  Future<void> _handleRequestOtp(
      RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(requestStatus: RequestStatus.requesting));

    try {
      final headers = await buildAuthHeaders();
      final response = await http.post(
          Uri.parse('$url/api/authentication/generateOtp'),
          body: json.encode({'phoneNumber': event.phoneNumber}),
          headers: headers);
      if (response.statusCode == 200) {
        emit(state.copyWith(requestStatus: RequestStatus.success));
      } else if (response.statusCode == 502) {
        emit(state.copyWith(requestStatus: RequestStatus.internalServerError));
      } else if (response.statusCode == 404) {
        emit(state.copyWith(requestStatus: RequestStatus.numberNotFound));
      } else {
        emit(state.copyWith(requestStatus: RequestStatus.failed));
      }
    } catch (e) {
      emit(state.copyWith(requestStatus: RequestStatus.failed));
    }
  }

  Future<void> _handleVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verificationStatus: VerificationStatus.requested));
    final deviceId = await getDeviceId();
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    try {
      final headers = await buildAuthHeaders();
      final response = await http.post(
        Uri.parse('$url/api/authentication/verifyOtp'),
        headers: headers,
        body: json.encode({
          'phoneNumber': event.phoneNumber,
          'otp': event.otp,
          'deviceId': deviceId,
          'name': event.name,
          'firebaseUid': firebaseUid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final customToken = data['customToken']?.toString();

        if (customToken == null || customToken.isEmpty) {
          emit(state.copyWith(
              verificationStatus: VerificationStatus.networkFailure));
          return;
        }

        await FirebaseAuth.instance.signInWithCustomToken(customToken);
        if (event.name.trim().isNotEmpty) {
          await FirebaseAuth.instance.currentUser
              ?.updateDisplayName(event.name.trim());
        }

        await cacheUserInfo(
          name: event.name,
          phone: event.phoneNumber,
        );

        if (response.statusCode == 201) {
          emit(state.copyWith(verificationStatus: VerificationStatus.success));
        } else {
          emit(state.copyWith(verificationStatus: VerificationStatus.found));
        }

        try {
          await deviceInfo();
        } catch (e) {
          // Device info is optional; ignore errors.
        }
      } else if (response.statusCode == 502) {
        emit(state.copyWith(
          verificationStatus: VerificationStatus.internalServerError,
        ));
      } else if (response.statusCode == 400) {
        emit(state.copyWith(verificationStatus: VerificationStatus.otpError));
      } else if (response.statusCode == 401) {
        emit(state.copyWith(verificationStatus: VerificationStatus.otpExpired));
      } else {
        emit(state.copyWith(
          verificationStatus: VerificationStatus.networkFailure,
        ));
      }
    } catch (e) {
      print('error happened ');
      emit(state.copyWith(
        verificationStatus: VerificationStatus.networkFailure,
      ));
    }
  }
}
