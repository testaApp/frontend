import '../../models/social_media/social_media_model.dart';

enum postRequest {
  unknown,
  requestInProgress,
  requestSuccess,
  requestFailure,
  requesting,
}

class SocialMediaState {
  SocialMediaState({
    this.facebookPosts = const [],
    this.facebookRequest = postRequest.unknown,
    this.twitterPosts = const [],
    this.twitterRequest = postRequest.unknown,
    this.instagramPosts = const [],
    this.instagramRequest = postRequest.unknown,
    this.telegramPosts = const [],
    this.telegramRequest = postRequest.unknown,
    this.faceBookPageNumber = 2,
    this.twitterPageNumber = 1,
    this.telegramPageNumber = 1,
    this.instagramPageNumber = 1,
    this.facebookLoading = false,
    this.twitterLoading = false,
    this.instagramLoading = false,
    this.telegramLoading = false,
  });

  final List<PostModel> facebookPosts;
  final postRequest facebookRequest;
  final int faceBookPageNumber;
  final List<PostModel> twitterPosts;
  final postRequest twitterRequest;
  final int twitterPageNumber;
  final List<PostModel> telegramPosts;
  final postRequest telegramRequest;
  final int telegramPageNumber;
  final List<PostModel> instagramPosts;
  final postRequest instagramRequest;
  final int instagramPageNumber;
  final bool facebookLoading;
  final bool twitterLoading;
  final bool instagramLoading;
  final bool telegramLoading;

  SocialMediaState copyWith({
    List<PostModel>? facebookPosts,
    postRequest? facebookRequest,
    List<PostModel>? twitterPosts,
    postRequest? twitterRequest,
    List<PostModel>? telegramPosts,
    postRequest? telegramRequest,
    List<PostModel>? instagramPosts,
    postRequest? instagramRequest,
    int? faceBookPageNumber,
    int? instagramPageNumber,
    int? telegramPageNumber,
    int? twitterPageNumber,
    bool? facebookLoading,
    bool? twitterLoading,
    bool? instagramLoading,
    bool? telegramLoading,
  }) =>
      SocialMediaState(
        facebookPosts: facebookPosts ?? this.facebookPosts,
        facebookRequest: facebookRequest ?? this.facebookRequest,
        twitterPosts: twitterPosts ?? this.twitterPosts,
        twitterRequest: twitterRequest ?? this.twitterRequest,
        telegramPosts: telegramPosts ?? this.telegramPosts,
        telegramRequest: telegramRequest ?? this.telegramRequest,
        instagramPosts: instagramPosts ?? this.instagramPosts,
        instagramRequest: instagramRequest ?? this.instagramRequest,
        faceBookPageNumber: faceBookPageNumber ?? this.faceBookPageNumber,
        instagramPageNumber: instagramPageNumber ?? this.instagramPageNumber,
        telegramPageNumber: telegramPageNumber ?? this.telegramPageNumber,
        twitterPageNumber: twitterPageNumber ?? this.twitterPageNumber,
        facebookLoading: facebookLoading ?? this.facebookLoading,
        twitterLoading: twitterLoading ?? this.twitterLoading,
        instagramLoading: instagramLoading ?? this.instagramLoading,
        telegramLoading: telegramLoading ?? this.telegramLoading,
      );
}
