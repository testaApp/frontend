import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../pages/entry_pages/device_info.dart';
import '../../util/auth/getDeviceInfo.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
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
      // Try to get existing token, but allow anonymous requests
      String? accessToken;
      try {
        accessToken = await getAccessToken();
      } catch (e) {
        // No token available - continue with anonymous request
      }

      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (accessToken != null) {
        headers['accesstoken'] = accessToken;
      }

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
    String deviceId = await getDeviceId();

    // Try to get existing token, but allow anonymous requests
    String? token;
    try {
      token = await getAccessToken();
    } catch (e) {
      // No token available - continue with anonymous request
      print('No access token found, making anonymous OTP verification');
    }

    print('device id is $deviceId');

    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['accesstoken'] = token;
      }

      final response = await http.post(
        Uri.parse('$url/api/authentication/verifyOtp'),
        headers: headers,
        body: json.encode({
          'phoneNumber': event.phoneNumber,
          'otp': event.otp,
          'deviceId': deviceId,
          'name': event.name,
        }),
      );

      if (response.statusCode == 201) {
        emit(state.copyWith(verificationStatus: VerificationStatus.success));
        await storeAccessToken(jsonDecode(response.body)['accessToken']);
        await storeRefreshToken(jsonDecode(response.body)['refreshToken']);
        // Send device info now that we have a valid access token
        try {
          await deviceInfo();
          print('Device info sent successfully after authentication');
        } catch (e) {
          print('Failed to send device info: $e');
        }
        print(jsonDecode(response.body)['refreshToken']);
      } else if (response.statusCode == 200) {
        emit(state.copyWith(verificationStatus: VerificationStatus.found));
        await storeAccessToken(jsonDecode(response.body)['accessToken']);
        // Send device info now that we have a valid access token
        try {
          await deviceInfo();
          print('Device info sent successfully after authentication');
        } catch (e) {
          print('Failed to send device info: $e');
        }
        // await storeRefreshToken(jsonDecode(response.body)['refreshToken']);
        print(response.body);
        print(jsonDecode(response.body)['refreshToken']);
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
