import 'package:bloc/bloc.dart';

import 'package:blogapp/models/fixtures/stat.dart';
import 'package:blogapp/models/standings/standings.dart';
import 'package:blogapp/data/repositories/matches_repository.dart';
import 'package:blogapp/data/repositories/standing_repo.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc() : super(ContentState()) {
    on<ContentEvent>((event, emit) {});
    on<StandingRequested>(_handleStandingRequested);
    on<ChangePageRequested>(_handleChangePageRequested);
    on<FetchLeagueFixture>(_handleFetchLeagueFixture);
    on<FetchFixtureByDate>(_handleFixtureByDate);
    on<PlayerStatRequested>(_handlePlayerStatRequested);
    on<KnockOutRequested>(_handleKnockOutRequested);
    on<SeasonRequested>(_handleSeasonRequested);
    on<RequestFixtureListByLeagueId>(_handleFixtureListByLeague);
    on<FetchTodaysLeagueMatches>(_handleFetchTodaysLeagueMatches);
  }

  bool _hasStandingsData(Map<String, List<List<TableItem>>> data) {
    final overall = data['overall'];
    if (overall == null || overall.isEmpty) return false;
    final firstGroup = overall.first;
    if (firstGroup.isEmpty) return false;
    return true;
  }

  String? _resolveSeason(
      Map<String, List<List<TableItem>>> data, String? fallback) {
    final overall = data['overall'];
    if (overall != null && overall.isNotEmpty && overall.first.isNotEmpty) {
      return overall.first.first.season ?? fallback;
    }
    return fallback;
  }

  Future<void> _handleStandingRequested(
      StandingRequested event, Emitter<ContentState> emit) async {
    List<List<TableItem>> emptyList = [];

    // Emit request in progress state
    emit(state.copyWith(
      status: ContentStatus.requestInProgress,
      leagueId: event.leagueId,
      currentLeagueId: event.leagueId,
      season: event.season ?? state.season,
      nestedList: {
        'overall': emptyList,
        'home': emptyList,
        'away': emptyList,
      },
    ));

    final response =
        await getNewerStanding(leagueId: event.leagueId, season: event.season);

    await response.fold((failure) async {
      // If current season fails, try previous season
      if (event.season != null) {
        final previousYear = (int.parse(event.season!) - 1).toString();
        final retryResponse = await getNewerStanding(
            leagueId: event.leagueId, season: previousYear);

        retryResponse.fold(
            (failure) =>
                emit(state.copyWith(status: ContentStatus.requestFailed)),
            (success) {
              if (!_hasStandingsData(success)) {
                emit(state.copyWith(
                  status: ContentStatus.requestFailed,
                  nestedList: success,
                  leagueId: event.leagueId,
                  currentLeagueId: event.leagueId,
                  season: previousYear,
                  errorMessage: 'No standings data',
                ));
                return;
              }

              emit(state.copyWith(
                status: ContentStatus.requestSuccessed,
                nestedList: success,
                leagueId: event.leagueId,
                currentLeagueId: event.leagueId,
                season: _resolveSeason(success, previousYear),
              ));
            });
      } else {
        emit(state.copyWith(status: ContentStatus.requestFailed));
      }
    }, (success) {
      if (!_hasStandingsData(success)) {
        emit(state.copyWith(
          status: ContentStatus.requestFailed,
          nestedList: success,
          leagueId: event.leagueId,
          currentLeagueId: event.leagueId,
          season: event.season,
          errorMessage: 'No standings data',
        ));
        return;
      }

      emit(state.copyWith(
        status: ContentStatus.requestSuccessed,
        nestedList: success,
        leagueId: event.leagueId,
        currentLeagueId: event.leagueId,
        season: _resolveSeason(success, event.season),
      ));
    });
  }
  // print('response is ${reponse}');

  void _handleChangePageRequested(
      ChangePageRequested event, Emitter<ContentState> emit) {
    state.currentPage != event.pagename
        ? emit(state.copyWith(currentPage: event.pagename))
        : null;
  }

  Future<void> _handleFetchLeagueFixture(
      FetchLeagueFixture event, Emitter<ContentState> emit) async {
    MatchApiDataSource api = MatchApiDataSource();
    final response = await api.getFixturesByLeagueId(leagueId: event.leagueId);

    response.fold(
        (l) => emit(state.copyWith(
            status: ContentStatus.requestFailed, leagueFixtures: [])), (r) {
      List<Stat> premierLeagueMatches =
          r.where((match) => match.leagueId == 39).toList();

      final saudiLeagueMatches =
          r.where((match) => match.leagueId == 307).toList();
      final championsLeagueMatches =
          r.where((match) => match.leagueId == 2).toList();
      final ethioLeagueMatches =
          r.where((match) => match.leagueId == 363).toList();

      final laligaMatches = r.where((match) => match.leagueId == 140).toList();
      final league1Matches = r.where((match) => match.leagueId == 61).toList();
      final sereaMatches = r.where((match) => match.leagueId == 135).toList();
      final bundesLigaMatches =
          r.where((match) => match.leagueId == 78).toList();
      final europaLeagueMatches =
          r.where((match) => match.leagueId == 3).toList();
      final facupMatches = r.where((match) => match.leagueId == 45).toList();
      final carabaoMatches = r.where((match) => match.leagueId == 48).toList();
      final africanWcQualification =
          r.where((match) => match.leagueId == 29).toList();
      final europeanWcQualification =
          r.where((match) => match.leagueId == 32).toList();
      final asianWcQualification =
          r.where((match) => match.leagueId == 30).toList();
      final northAmericanWcQualification =
          r.where((match) => match.leagueId == 31).toList();
      final southAmericanWcQualification =
          r.where((match) => match.leagueId == 34).toList();
      final oceaniaWcQualification =
          r.where((match) => match.leagueId == 33).toList();

      final englishLeagueTwoMatches =
          r.where((match) => match.leagueId == 42).toList();
      final englishChampionshipMatches =
          r.where((match) => match.leagueId == 40).toList();
      final europaNationsLeagueMatches =
          r.where((match) => match.leagueId == 5).toList();
      final africanCupMatches =
          r.where((match) => match.leagueId == 6).toList();
      final europeanCupMatches =
          r.where((match) => match.leagueId == 4).toList();
      final eredivisieMatches =
          r.where((match) => match.leagueId == 88).toList();
      final jupileProLeagueMatches =
          r.where((match) => match.leagueId == 144).toList();
      final premiershipMatches =
          r.where((match) => match.leagueId == 179).toList();
      final turkLeagueMatches =
          r.where((match) => match.leagueId == 203).toList();
      final premieraLigaMatches =
          r.where((match) => match.leagueId == 94).toList();

      final copaAmericaMatches =
          r.where((match) => match.leagueId == 9).toList();
      final olympicsmenmatchs =
          r.where((match) => match.leagueId == 480).toList();
      final asianCupMatches = r.where((match) => match.leagueId == 7).toList();
      final goldCupMatches = r.where((match) => match.leagueId == 22).toList();
      final africanFootballLeagueMatches =
          r.where((match) => match.leagueId == 1043).toList();
      final afcChampionsLeagueMatches =
          r.where((match) => match.leagueId == 17).toList();
      final afcCupMatches = r.where((match) => match.leagueId == 18).toList();
      final cafChampionsLeagueMatches =
          r.where((match) => match.leagueId == 12).toList();
      final cafConfederationCupMatches =
          r.where((match) => match.leagueId == 20).toList();
      final africanNationsChampionshipMatches =
          r.where((match) => match.leagueId == 19).toList();
      final spainSegundaDivisionMatches =
          r.where((match) => match.leagueId == 141).toList();
      final southAfricaPremierSoccerLeagueMatches =
          r.where((match) => match.leagueId == 288).toList();
      final italySerieBMatches =
          r.where((match) => match.leagueId == 136).toList();
      final serieCMatches = r.where((match) => match.leagueId == 138).toList();
      final turkeyLig1Matches =
          r.where((match) => match.leagueId == 204).toList();

      final friendlyMatches = r.where((match) => match.leagueId == 10).toList();
      final qatarStarsLeagueMatches =
          r.where((match) => match.leagueId == 305).toList();
      final belgiumChallengerProLeagueMatches =
          r.where((match) => match.leagueId == 145).toList();
      final netherlandsEersteDivisieMatches =
          r.where((match) => match.leagueId == 89).toList();
      final portugalLigaPortugalMatches =
          r.where((match) => match.leagueId == 95).toList();
      final germanyBundesliga2Matches =
          r.where((match) => match.leagueId == 79).toList();
      final germanyLiga3Matches =
          r.where((match) => match.leagueId == 80).toList();
      final franceLigue2Matches =
          r.where((match) => match.leagueId == 62).toList();
      final championnatNationalMatches =
          r.where((match) => match.leagueId == 63).toList();
      final brazilSerieAMatches =
          r.where((match) => match.leagueId == 71).toList();
      final brazilSerieBMatches =
          r.where((match) => match.leagueId == 72).toList();
      final brazilSerieCMatches =
          r.where((match) => match.leagueId == 75).toList();
      final ligaProfesionalArgentinaMatches =
          r.where((match) => match.leagueId == 128).toList();
      final argentinaPrimeraNacionalMatches =
          r.where((match) => match.leagueId == 129).toList();
      final copaArgentinaMatches =
          r.where((match) => match.leagueId == 130).toList();
      final usaMajorLeagueSoccerMatches =
          r.where((match) => match.leagueId == 253).toList();
      final uslChampionshipMatches =
          r.where((match) => match.leagueId == 255).toList();
      final uslLeagueOneMatches =
          r.where((match) => match.leagueId == 489).toList();
      final egyptPremierLeagueMatches =
          r.where((match) => match.leagueId == 233).toList();
      final ghanaPremierLeagueMatches =
          r.where((match) => match.leagueId == 570).toList();
      final scotlandChampionshipMatches =
          r.where((match) => match.leagueId == 180).toList();
      emit(state.copyWith(
        status: ContentStatus.requestSuccessed,
        premierLeagueMatches: premierLeagueMatches,
        saudiLeagueMatches: saudiLeagueMatches,
        championsLeagueMatches: championsLeagueMatches,
        ethioLeagueMatches: ethioLeagueMatches,
        laligaMatches: laligaMatches,
        league1Matches: league1Matches,
        sereaMatches: sereaMatches,
        europaLeagueMatches: europaLeagueMatches,
        facupMatches: facupMatches,
        carabaoMatches: carabaoMatches,
        bundesLigaMatches: bundesLigaMatches,
        african_wc_qualification: africanWcQualification,
        european_wc_qualification: europeanWcQualification,
        asian_wc_qualification: asianWcQualification,
        north_american_wc_qualification: northAmericanWcQualification,
        south_american_wc_qualification: southAmericanWcQualification,
        oceania_wc_qualification: oceaniaWcQualification,
        englishChampionshipMatches: englishChampionshipMatches,
        // englishLeagueOneMatches: englishLeagueOneMatches,
        englishLeagueTwoMatches: englishLeagueTwoMatches,
        europaNationsLeagueMatches: europaNationsLeagueMatches,
        africanCupMatches: africanCupMatches,
        europeanCupMatches: europeanCupMatches,
        eredivisieMatches: eredivisieMatches,
        jupileProLeagueMatches: jupileProLeagueMatches,
        premiershipMatches: premiershipMatches,
        turkLeagueMatches: turkLeagueMatches,
        premieraLigaMatches: premieraLigaMatches,

        copaAmericaMatches: copaAmericaMatches,
        olympicsmenmatchs: olympicsmenmatchs,
        asianCupMatches: asianCupMatches,
        goldCupMatches: goldCupMatches,
        africanFootballLeagueMatches: africanFootballLeagueMatches,
        afcChampionsLeagueMatches: afcChampionsLeagueMatches,
        afcCupMatches: afcCupMatches,
        cafChampionsLeagueMatches: cafChampionsLeagueMatches,
        cafConfederationCupMatches: cafConfederationCupMatches,
        africanNationsChampionshipMatches: africanNationsChampionshipMatches,
        spainSegundaDivisionMatches: spainSegundaDivisionMatches,
        southAfricaPremierSoccerLeagueMatches:
            southAfricaPremierSoccerLeagueMatches,
        italySerieBMatches: italySerieBMatches,
        serieCMatches: serieCMatches,
        turkeyLig1Matches: turkeyLig1Matches,
        friendlyMatches: friendlyMatches,
        qatarStarsLeagueMatches: qatarStarsLeagueMatches,
        belgiumChallengerProLeagueMatches: belgiumChallengerProLeagueMatches,
        netherlandsEersteDivisieMatches: netherlandsEersteDivisieMatches,
        portugalLigaPortugalMatches: portugalLigaPortugalMatches,
        germanyBundesliga2Matches: germanyBundesliga2Matches,
        germanyLiga3Matches: germanyLiga3Matches,
        franceLigue2Matches: franceLigue2Matches,
        championnatNationalMatches: championnatNationalMatches,
        brazilSerieAMatches: brazilSerieAMatches,
        brazilSerieBMatches: brazilSerieBMatches,
        brazilSerieCMatches: brazilSerieCMatches,
        ligaProfesionalArgentinaMatches: ligaProfesionalArgentinaMatches,
        argentinaPrimeraNacionalMatches: argentinaPrimeraNacionalMatches,
        copaArgentinaMatches: copaArgentinaMatches,
        usaMajorLeagueSoccerMatches: usaMajorLeagueSoccerMatches,
        uslChampionshipMatches: uslChampionshipMatches,
        uslLeagueOneMatches: uslLeagueOneMatches,
        egyptPremierLeagueMatches: egyptPremierLeagueMatches,
        ghanaPremierLeagueMatches: ghanaPremierLeagueMatches,
        scotlandChampionshipMatches: scotlandChampionshipMatches,
        // nestedList: []
      ));
    });
  }

  Future<void> _handleFixtureByDate(
      FetchFixtureByDate event, Emitter<ContentState> emit) async {
    emit(state.copyWith(status: ContentStatus.requestInProgress));

    try {
      MatchApiDataSource api = MatchApiDataSource();
      final response = await api.getFixturesByDate(
          leagueId: event.leagueId, date: event.pickedDate);

      response.fold(
          (failure) => emit(state.copyWith(
                status: ContentStatus.requestFailed,
                errorMessage: 'Network Error', // Generic error message
              )), (r) {
        List<Stat> premierLeagueMatches =
            r.where((match) => match.leagueId == 39).toList();
        final friendlyMatches =
            r.where((match) => match.leagueId == 10).toList();

        final saudiLeagueMatches =
            r.where((match) => match.leagueId == 307).toList();
        final championsLeagueMatches =
            r.where((match) => match.leagueId == 2).toList();
        final ethioLeagueMatches =
            r.where((match) => match.leagueId == 363).toList();
        final laligaMatches =
            r.where((match) => match.leagueId == 140).toList();
        final league1Matches =
            r.where((match) => match.leagueId == 61).toList();
        final sereaMatches = r.where((match) => match.leagueId == 135).toList();
        final europaLeagueMatches =
            r.where((match) => match.leagueId == 3).toList();
        final facupMatches = r.where((match) => match.leagueId == 45).toList();
        final carabaoMatches =
            r.where((match) => match.leagueId == 48).toList();
        final bundesLigaMatches =
            r.where((match) => match.leagueId == 78).toList();
        final africanWcQualification =
            r.where((match) => match.leagueId == 29).toList();
        final europeanWcQualification =
            r.where((match) => match.leagueId == 32).toList();
        final asianWcQualification =
            r.where((match) => match.leagueId == 30).toList();
        final northAmericanWcQualification =
            r.where((match) => match.leagueId == 31).toList();
        final southAmericanWcQualification =
            r.where((match) => match.leagueId == 34).toList();
        final oceaniaWcQualification =
            r.where((match) => match.leagueId == 33).toList();
        final englishLeagueTwoMatches =
            r.where((match) => match.leagueId == 42).toList();
        final englishChampionshipMatches =
            r.where((match) => match.leagueId == 40).toList();
        final europaNationsLeagueMatches =
            r.where((match) => match.leagueId == 5).toList();
        final africanCupMatches =
            r.where((match) => match.leagueId == 6).toList();
        final europeanCupMatches =
            r.where((match) => match.leagueId == 4).toList();

        final eredivisieMatches =
            r.where((match) => match.leagueId == 88).toList();
        final jupileProLeagueMatches =
            r.where((match) => match.leagueId == 144).toList();
        final premiershipMatches =
            r.where((match) => match.leagueId == 179).toList();
        final turkLeagueMatches =
            r.where((match) => match.leagueId == 203).toList();
        final premieraLigaMatches =
            r.where((match) => match.leagueId == 94).toList();

        final copaAmericaMatches =
            r.where((match) => match.leagueId == 9).toList();
        final olympicsmenmatchs =
            r.where((match) => match.leagueId == 480).toList();
        final asianCupMatches =
            r.where((match) => match.leagueId == 7).toList();
        final goldCupMatches =
            r.where((match) => match.leagueId == 22).toList();
        final africanFootballLeagueMatches =
            r.where((match) => match.leagueId == 1043).toList();
        final afcChampionsLeagueMatches =
            r.where((match) => match.leagueId == 17).toList();
        final afcCupMatches = r.where((match) => match.leagueId == 18).toList();
        final cafChampionsLeagueMatches =
            r.where((match) => match.leagueId == 12).toList();
        final cafConfederationCupMatches =
            r.where((match) => match.leagueId == 20).toList();
        final africanNationsChampionshipMatches =
            r.where((match) => match.leagueId == 19).toList();
        final spainSegundaDivisionMatches =
            r.where((match) => match.leagueId == 141).toList();
        final southAfricaPremierSoccerLeagueMatches =
            r.where((match) => match.leagueId == 288).toList();
        final italySerieBMatches =
            r.where((match) => match.leagueId == 136).toList();
        final serieCMatches =
            r.where((match) => match.leagueId == 138).toList();
        final turkeyLig1Matches =
            r.where((match) => match.leagueId == 204).toList();

        final qatarStarsLeagueMatches =
            r.where((match) => match.leagueId == 305).toList();
        final belgiumChallengerProLeagueMatches =
            r.where((match) => match.leagueId == 145).toList();
        final netherlandsEersteDivisieMatches =
            r.where((match) => match.leagueId == 89).toList();
        final portugalLigaPortugalMatches =
            r.where((match) => match.leagueId == 95).toList();
        final germanyBundesliga2Matches =
            r.where((match) => match.leagueId == 79).toList();
        final germanyLiga3Matches =
            r.where((match) => match.leagueId == 80).toList();
        final franceLigue2Matches =
            r.where((match) => match.leagueId == 62).toList();
        final championnatNationalMatches =
            r.where((match) => match.leagueId == 63).toList();
        final brazilSerieAMatches =
            r.where((match) => match.leagueId == 71).toList();
        final brazilSerieBMatches =
            r.where((match) => match.leagueId == 72).toList();
        final brazilSerieCMatches =
            r.where((match) => match.leagueId == 75).toList();
        final ligaProfesionalArgentinaMatches =
            r.where((match) => match.leagueId == 128).toList();
        final argentinaPrimeraNacionalMatches =
            r.where((match) => match.leagueId == 129).toList();
        final copaArgentinaMatches =
            r.where((match) => match.leagueId == 130).toList();
        final usaMajorLeagueSoccerMatches =
            r.where((match) => match.leagueId == 253).toList();
        final uslChampionshipMatches =
            r.where((match) => match.leagueId == 255).toList();
        final uslLeagueOneMatches =
            r.where((match) => match.leagueId == 489).toList();
        final egyptPremierLeagueMatches =
            r.where((match) => match.leagueId == 233).toList();
        final ghanaPremierLeagueMatches =
            r.where((match) => match.leagueId == 570).toList();
        final scotlandChampionshipMatches =
            r.where((match) => match.leagueId == 180).toList();

        emit(state.copyWith(
          status: ContentStatus.requestSuccessed,
          premierLeagueMatches: premierLeagueMatches,
          saudiLeagueMatches: saudiLeagueMatches,
          championsLeagueMatches: championsLeagueMatches,
          ethioLeagueMatches: ethioLeagueMatches,
          laligaMatches: laligaMatches,
          league1Matches: league1Matches,
          sereaMatches: sereaMatches,
          europaLeagueMatches: europaLeagueMatches,
          friendlyMatches: friendlyMatches,
          facupMatches: facupMatches,
          carabaoMatches: carabaoMatches,
          bundesLigaMatches: bundesLigaMatches,
          african_wc_qualification: africanWcQualification,
          european_wc_qualification: europeanWcQualification,
          asian_wc_qualification: asianWcQualification,
          north_american_wc_qualification: northAmericanWcQualification,
          south_american_wc_qualification: southAmericanWcQualification,
          oceania_wc_qualification: oceaniaWcQualification,
          englishChampionshipMatches: englishChampionshipMatches,
          englishLeagueTwoMatches: englishLeagueTwoMatches,
          europaNationsLeagueMatches: europaNationsLeagueMatches,
          africanCupMatches: africanCupMatches,
          europeanCupMatches: europeanCupMatches,

          eredivisieMatches: eredivisieMatches,
          jupileProLeagueMatches: jupileProLeagueMatches,
          premiershipMatches: premiershipMatches,
          turkLeagueMatches: turkLeagueMatches,
          premieraLigaMatches: premieraLigaMatches,

          copaAmericaMatches: copaAmericaMatches,
          olympicsmenmatchs: olympicsmenmatchs,
          asianCupMatches: asianCupMatches,
          goldCupMatches: goldCupMatches,
          africanFootballLeagueMatches: africanFootballLeagueMatches,
          afcChampionsLeagueMatches: afcChampionsLeagueMatches,
          afcCupMatches: afcCupMatches,
          cafChampionsLeagueMatches: cafChampionsLeagueMatches,
          cafConfederationCupMatches: cafConfederationCupMatches,
          africanNationsChampionshipMatches: africanNationsChampionshipMatches,
          spainSegundaDivisionMatches: spainSegundaDivisionMatches,
          southAfricaPremierSoccerLeagueMatches:
              southAfricaPremierSoccerLeagueMatches,
          italySerieBMatches: italySerieBMatches,
          serieCMatches: serieCMatches,
          turkeyLig1Matches: turkeyLig1Matches,
          qatarStarsLeagueMatches: qatarStarsLeagueMatches,
          belgiumChallengerProLeagueMatches: belgiumChallengerProLeagueMatches,
          netherlandsEersteDivisieMatches: netherlandsEersteDivisieMatches,
          portugalLigaPortugalMatches: portugalLigaPortugalMatches,
          germanyBundesliga2Matches: germanyBundesliga2Matches,
          germanyLiga3Matches: germanyLiga3Matches,
          franceLigue2Matches: franceLigue2Matches,
          championnatNationalMatches: championnatNationalMatches,
          brazilSerieAMatches: brazilSerieAMatches,
          brazilSerieBMatches: brazilSerieBMatches,
          brazilSerieCMatches: brazilSerieCMatches,
          ligaProfesionalArgentinaMatches: ligaProfesionalArgentinaMatches,
          argentinaPrimeraNacionalMatches: argentinaPrimeraNacionalMatches,
          copaArgentinaMatches: copaArgentinaMatches,
          usaMajorLeagueSoccerMatches: usaMajorLeagueSoccerMatches,
          uslChampionshipMatches: uslChampionshipMatches,
          uslLeagueOneMatches: uslLeagueOneMatches,
          egyptPremierLeagueMatches: egyptPremierLeagueMatches,
          ghanaPremierLeagueMatches: ghanaPremierLeagueMatches,
          scotlandChampionshipMatches: scotlandChampionshipMatches,
          // nestedList: []
        ));
      });
    } catch (e) {
      emit(state.copyWith(
        status: ContentStatus.requestFailed,
        errorMessage: 'Network Error', // Generic error message
      ));
    }
  }

  Future<void> _handlePlayerStatRequested(
      PlayerStatRequested event, Emitter<ContentState> emit) async {
    emit(state.copyWith(currentPage: ContentStatus.playerStat));
  }

  Future<void> _handleKnockOutRequested(
      KnockOutRequested event, Emitter<ContentState> emit) async {
    emit(state.copyWith(currentPage: ContentStatus.knockout));
  }

  Future<void> _handleSeasonRequested(
      SeasonRequested event, Emitter<ContentState> emit) async {
    emit(state.copyWith(currentPage: ContentStatus.seasons));
  }

  Future<void> _handleFixtureListByLeague(
      RequestFixtureListByLeagueId event, Emitter<ContentState> emit) async {
    print(
        '🎯 Fetching fixtures for league ${event.leagueId} and season ${event.season}');
    emit(state.copyWith(fixtureListStatus: ContentStatus.requestInProgress));

    try {
      MatchApiDataSource api = MatchApiDataSource();
      final response = await api.getFixtureListByLeague(
        leagueId: event.leagueId,
        season: event.season, // Pass the season parameter
      );

      response.fold(
        (failure) {
          print('❌ Failed to fetch fixtures: ${failure.message}');
          emit(state.copyWith(
            fixtureListStatus: ContentStatus.requestFailed,
            errorMessage: failure.message,
          ));
        },
        (success) {
          emit(state.copyWith(
            fixtureListStatus: ContentStatus.requestSuccessed,
            listOfLeagueFixtures: success,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        fixtureListStatus: ContentStatus.requestFailed,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _handleFetchTodaysLeagueMatches(
      FetchTodaysLeagueMatches event, Emitter<ContentState> emit) async {
    print('🏁 Starting to fetch today\'s matches');
    emit(state.copyWith(status: ContentStatus.requestInProgress));

    try {
      MatchApiDataSource api = MatchApiDataSource();
      final response = await api.getTodaysLeagueMatches();

      response.fold((failure) {
        print('❌ Failed to fetch matches: ${failure.message}');
        emit(state.copyWith(
            status: ContentStatus.requestFailed,
            errorMessage: failure.message,
            todaysMatches: []));
      }, (matches) {
        print('✅ Successfully fetched ${matches.length} matches');
        emit(state.copyWith(
            status: ContentStatus.requestSuccessed, todaysMatches: matches));
      });
    } catch (e, stackTrace) {
      print('💥 Unexpected error in bloc: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
          status: ContentStatus.requestFailed,
          errorMessage: 'Unexpected error: $e',
          todaysMatches: []));
    }
  }
}
