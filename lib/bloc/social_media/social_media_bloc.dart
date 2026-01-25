import 'dart:convert';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/social_media/social_media_model.dart';
import '../../util/baseUrl.dart';
import 'social_media_event.dart';
import 'social_media_state.dart';

class SocialMediaBloc extends Bloc<SocialMediaEvent, SocialMediaState> {
  SocialMediaBloc() : super(SocialMediaState()) {
    on<SocialMediaEvent>((event, emit) {});
    on<FacebookPostsRequested>(_handleFbRequested);
    on<TwitterPostsRequested>(_handleTwitterRequested);
    on<InstagramPostsRequested>(_handleInstagramRequested);
    on<TelegramPostsRequested>(_handleTelegramPostsRequested);
    on<LoadNextPageFacebook>(_handleFbNextPageRequested);
    on<LoadNextPageTwitter>(_handleTwitterNextPageRequested);
    on<LoadNextPageInstagram>(_handleInstagramNextPageRequested);
    on<LoadNextPageTelegram>(_handleTelegramNextPageRequested);
  }

  String url = BaseUrl().url;

  Future<void> _handleFbRequested(
      FacebookPostsRequested event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(facebookRequest: postRequest.requestInProgress));
    try {
      final response = await http.get(
        Uri.parse('$url/api/socialmedia/social?source="facebook"&pageNumber=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) => PostModel.forFacebook(item as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          facebookRequest: postRequest.requestSuccess,
          facebookPosts: posts,
          faceBookPageNumber: 2,
        ));
      } else {
        emit(state.copyWith(facebookRequest: postRequest.requestFailure));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(facebookRequest: postRequest.requestFailure));
    }
  }

  Future<void> _handleFbNextPageRequested(
      LoadNextPageFacebook event, Emitter<SocialMediaState> emit) async {
    if (state.facebookLoading == true) {
      return;
    }
    try {
      emit(state.copyWith(facebookLoading: true));
      final response = await http.get(
        Uri.parse(
            '$url/api/socialmedia/social?source="facebook"&pageNumber=${state.faceBookPageNumber}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) => PostModel.forFacebook(item as Map<String, dynamic>))
            .toList();

        final updatedPosts = [...state.facebookPosts, ...posts];
        emit(state.copyWith(
          facebookRequest: postRequest.requestSuccess,
          facebookLoading: false,
          faceBookPageNumber: state.faceBookPageNumber + 1,
          facebookPosts: updatedPosts,
        ));
      } else {
        emit(state.copyWith(
          facebookRequest: postRequest.requestFailure,
          facebookLoading: false,
        ));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(
        facebookRequest: postRequest.requestFailure,
        facebookLoading: false,
      ));
    }
  }

  Future<void> _handleTwitterRequested(
      TwitterPostsRequested event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(twitterRequest: postRequest.requestInProgress));
    try {
      final response = await http.get(
        Uri.parse('$url/api/socialmedia/social?source="twitter"&pageNumber=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> twitterposts = responseList
            .map((item) => PostModel.forTwitter(item as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          twitterRequest: postRequest.requestSuccess,
          twitterPosts: twitterposts,
          twitterPageNumber: 1,
        ));
      } else {
        emit(state.copyWith(twitterRequest: postRequest.requestFailure));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(twitterRequest: postRequest.requestFailure));
    }
  }

  Future<void> _handleTwitterNextPageRequested(
      LoadNextPageTwitter event, Emitter<SocialMediaState> emit) async {
    if (state.twitterLoading == true) {
      return;
    }
    try {
      emit(state.copyWith(twitterLoading: true));
      final response = await http.get(
        Uri.parse(
            '$url/api/socialmedia/social?source="twitter"&pageNumber=${state.twitterPageNumber}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) => PostModel.forTwitter(item as Map<String, dynamic>))
            .toList();

        final updatedPosts = [...state.twitterPosts, ...posts];
        emit(state.copyWith(
          twitterRequest: postRequest.requestSuccess,
          twitterLoading: false,
          twitterPageNumber: state.twitterPageNumber + 1,
          twitterPosts: updatedPosts,
        ));
      } else {
        emit(state.copyWith(
          twitterRequest: postRequest.requestFailure,
          twitterLoading: false,
        ));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(
        twitterRequest: postRequest.requestFailure,
        twitterLoading: false,
      ));
    }
  }

  Future<void> _handleInstagramRequested(
      InstagramPostsRequested event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(instagramRequest: postRequest.requestInProgress));
    try {
      final response = await http.get(
        Uri.parse(
            '$url/api/socialmedia/social?source="instagram"&pageNumber=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) =>
                PostModel.fromJsonForInsta(item as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          instagramRequest: postRequest.requestSuccess,
          instagramPosts: posts,
          instagramPageNumber: 1,
        ));
      } else {
        emit(state.copyWith(instagramRequest: postRequest.requestFailure));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(instagramRequest: postRequest.requestFailure));
    }
  }

  Future<void> _handleInstagramNextPageRequested(
      LoadNextPageInstagram event, Emitter<SocialMediaState> emit) async {
    if (state.instagramLoading == true) {
      return;
    }
    try {
      emit(state.copyWith(instagramLoading: true));
      final response = await http.get(
        Uri.parse(
            '$url/api/socialmedia/social?source="instagram"&pageNumber=${state.instagramPageNumber}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) =>
                PostModel.fromJsonForInsta(item as Map<String, dynamic>))
            .toList();

        final updatedPosts = [...state.instagramPosts, ...posts];
        emit(state.copyWith(
          instagramRequest: postRequest.requestSuccess,
          instagramLoading: false,
          instagramPageNumber: state.instagramPageNumber + 1,
          instagramPosts: updatedPosts,
        ));
      } else {
        emit(state.copyWith(
          instagramRequest: postRequest.requestFailure,
          instagramLoading: false,
        ));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(
        instagramRequest: postRequest.requestFailure,
        instagramLoading: false,
      ));
    }
  }

  Future<void> _handleTelegramPostsRequested(
      TelegramPostsRequested event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(telegramRequest: postRequest.requestInProgress));
    try {
      final response = await http.get(
        Uri.parse('$url/api/socialmedia/social?source="telegram"&pageNumber=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> telegramposts = responseList
            .map((item) => PostModel.forTelegram(item as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          telegramRequest: postRequest.requestSuccess,
          telegramPosts: telegramposts,
          telegramPageNumber: 1,
        ));
      } else {
        emit(state.copyWith(telegramRequest: postRequest.requestFailure));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(telegramRequest: postRequest.requestFailure));
    }
  }

  Future<void> _handleTelegramNextPageRequested(
      LoadNextPageTelegram event, Emitter<SocialMediaState> emit) async {
    if (state.telegramLoading == true) {
      return;
    }
    try {
      emit(state.copyWith(telegramLoading: true));
      final response = await http.get(
        Uri.parse(
            '$url/api/socialmedia/social?source="telegram"&pageNumber=${state.telegramPageNumber}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final responseList = responseData['response'] as List<dynamic>;

        List<PostModel> posts = responseList
            .map((item) => PostModel.forTelegram(item as Map<String, dynamic>))
            .toList();

        final updatedPosts = [...state.telegramPosts, ...posts];
        emit(state.copyWith(
          telegramRequest: postRequest.requestSuccess,
          telegramLoading: false,
          telegramPageNumber: state.telegramPageNumber + 1,
          telegramPosts: updatedPosts,
        ));
      } else {
        emit(state.copyWith(
          telegramRequest: postRequest.requestFailure,
          telegramLoading: false,
        ));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(
        telegramRequest: postRequest.requestFailure,
        telegramLoading: false,
      ));
    }
  }
}

List<dynamic> randomizeList(List<dynamic> list) {
  final random = Random();

  for (var i = list.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  return list;
}

List<dynamic> shuffleAndCombineResponses(List<http.Response> responses) {
  List<dynamic> combinedData = [];

  for (var response in responses) {
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['items'] as List<dynamic>;
      combinedData.addAll(responseData);
    }
  }

  final random = Random();
  for (var i = combinedData.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final temp = combinedData[i];
    combinedData[i] = combinedData[j];
    combinedData[j] = temp;
  }

  return combinedData;
}

Future<List<dynamic>> fetchRSSData(List<String> urls) async {
  final responses = await Future.wait(urls.map((url) => http.get(Uri.parse(url),
      headers: <String, String>{'Content-Type': 'application/json'})));

  return shuffleAndCombineResponses(responses);
}
