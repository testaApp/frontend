import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';

import 'package:blogapp/features/auth/services/oauth_config.dart';

class SocialAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    if (account == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _linkOrSignIn(credential);
  }

  static Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook sign-in failed');
    }

    final token = result.accessToken?.tokenString;
    if (token == null || token.isEmpty) {
      throw Exception('Missing Facebook access token');
    }

    final credential = FacebookAuthProvider.credential(token);
    return _linkOrSignIn(credential);
  }

  static Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return _linkOrSignIn(oauthCredential);
  }

  static Future<UserCredential> signInWithTwitter() async {
    if (OAuthConfig.twitterApiKey.isEmpty ||
        OAuthConfig.twitterApiSecret.isEmpty ||
        OAuthConfig.twitterRedirectUri.isEmpty) {
      throw Exception('Twitter OAuth config is missing');
    }

    final twitterLogin = TwitterLogin(
      apiKey: OAuthConfig.twitterApiKey,
      apiSecretKey: OAuthConfig.twitterApiSecret,
      redirectURI: OAuthConfig.twitterRedirectUri,
    );

    final authResult = await twitterLogin.login();
    if (authResult.status != TwitterLoginStatus.loggedIn) {
      throw Exception('X (Twitter) sign-in failed');
    }

    final session = authResult.authToken;
    final secret = authResult.authTokenSecret;
    if (session == null || secret == null) {
      throw Exception('Missing X (Twitter) auth tokens');
    }

    final credential = TwitterAuthProvider.credential(
      accessToken: session,
      secret: secret,
    );

    return _linkOrSignIn(credential);
  }

  static Future<UserCredential> _linkOrSignIn(
      AuthCredential credential) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        return await currentUser.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'provider-already-linked') {
          return await _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }
    return await _auth.signInWithCredential(credential);
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
