import '../../../models/fixtureByLeague.dart';
import '../../../models/fixtures/stat.dart';
import '../../../models/standings/standings.dart';
import 'package:equatable/equatable.dart';

enum ContentStatus {
  requestInProgress,
  requestSuccessed,
  requestFailed,
  unknown,
  standing,
  match,
  knockout,
  playerStat,
  seasons
}

class ContentState extends Equatable {
  ContentState({
    this.errorMessage = '',
    this.Content = const [],
    this.status = ContentStatus.unknown,
    this.nestedList = const {},
    this.currentPage = ContentStatus.standing,
    this.leagueFixtures = const [],
    this.leagueId,
    this.premierLeagueMatches = const [],
    this.saudiLeagueMatches = const [],
    this.championsLeagueMatches = const [],
    this.ethioLeagueMatches = const [],
    this.laligaMatches = const [],
    this.league1Matches = const [],
    this.sereaMatches = const [],
    this.europaLeagueMatches = const [],
    this.facupMatches = const [],
    this.carabaoMatches = const [],
    this.otherMatches = const [],
    this.bundesLigaMatches = const [],
    this.season,
    this.fixtureListStatus = ContentStatus.requestInProgress,
    this.african_wc_qualification = const [],
    this.european_wc_qualification = const [],
    this.asian_wc_qualification = const [],
    this.north_american_wc_qualification = const [],
    this.south_american_wc_qualification = const [],
    this.oceania_wc_qualification = const [],
    this.englishLeagueoneMatches = const [],
    this.englishLeagueTwoMatches = const [],
    this.englishChampionshipMatches = const [],
    this.europaNationsLeagueMatches = const [],
    this.europeanCupMatches = const [],
    this.africanCupMatches = const [],
    this.jupileProLeagueMatches = const [],
    this.eredivisieMatches = const [],
    this.premieraLigaMatches = const [],
    this.premiershipMatches = const [],
    this.premierSoccerLeagueMatches = const [],
    this.turkLeagueMatches = const [],
    this.copaAmericaMatches = const [],
    this.olympicsmenmatchs = const [],
    this.asianCupMatches = const [],
    this.goldCupMatches = const [],
    this.africanFootballLeagueMatches = const [],
    this.afcChampionsLeagueMatches = const [],
    this.afcCupMatches = const [],
    this.cafChampionsLeagueMatches = const [],
    this.cafConfederationCupMatches = const [],
    this.africanNationsChampionshipMatches = const [],
    this.spainSegundaDivisionMatches = const [],
    this.southAfricaPremierSoccerLeagueMatches = const [],
    this.italySerieBMatches = const [],
    this.serieCMatches = const [],
    this.turkeyLig1Matches = const [],
    this.friendlyMatches = const [],
    this.qatarStarsLeagueMatches = const [],
    this.belgiumChallengerProLeagueMatches = const [],
    this.netherlandsEersteDivisieMatches = const [],
    this.portugalLigaPortugalMatches = const [],
    this.germanyBundesliga2Matches = const [],
    this.germanyLiga3Matches = const [],
    this.franceLigue2Matches = const [],
    this.championnatNationalMatches = const [],
    this.brazilSerieAMatches = const [],
    this.brazilSerieBMatches = const [],
    this.brazilSerieCMatches = const [],
    this.ligaProfesionalArgentinaMatches = const [],
    this.argentinaPrimeraNacionalMatches = const [],
    this.copaArgentinaMatches = const [],
    this.usaMajorLeagueSoccerMatches = const [],
    this.uslChampionshipMatches = const [],
    this.uslLeagueOneMatches = const [],
    this.egyptPremierLeagueMatches = const [],
    this.ghanaPremierLeagueMatches = const [],
    this.scotlandChampionshipMatches = const [],
    this.listOfLeagueFixtures =
        const LeagueFixtures(previousMatches: [], upcomingMatches: []),
    this.todaysMatches = const [], // Add this new parameter
    this.currentLeagueId,
  });
  String errorMessage;

  List<TableItem> Content;
  ContentStatus status;
  ContentStatus fixtureListStatus;
  Map<String, List<List<TableItem>>> nestedList;
  ContentStatus currentPage;
  String? season;
  int? leagueId;
  List<Stat> leagueFixtures;
  List<Stat> premierLeagueMatches;
  List<Stat> saudiLeagueMatches;
  List<Stat> bundesLigaMatches;
  List<Stat> championsLeagueMatches;
  List<Stat> ethioLeagueMatches;
  List<Stat> laligaMatches;
  List<Stat> league1Matches;
  List<Stat> sereaMatches;
  List<Stat> europaLeagueMatches;
  List<Stat> facupMatches;
  List<Stat> carabaoMatches;
  List<Stat> african_wc_qualification;
  List<Stat> european_wc_qualification;
  List<Stat> asian_wc_qualification;
  List<Stat> north_american_wc_qualification;
  List<Stat> south_american_wc_qualification;
  List<Stat> oceania_wc_qualification;
  List<Stat> englishLeagueoneMatches;
  List<Stat> englishLeagueTwoMatches;
  List<Stat> englishChampionshipMatches;
  List<Stat> europaNationsLeagueMatches;
  List<Stat> europeanCupMatches;
  List<Stat> africanCupMatches;
  List<Stat> jupileProLeagueMatches;
  List<Stat> eredivisieMatches;
  List<Stat> premieraLigaMatches;
  List<Stat> premiershipMatches;
  List<Stat> premierSoccerLeagueMatches;
  List<Stat> turkLeagueMatches;
  LeagueFixtures listOfLeagueFixtures;
  List<Stat> otherMatches;

  // List<Stat> englishLeagueOneMatches;

  final List<Stat> copaAmericaMatches;
  final List<Stat> olympicsmenmatchs;
  final List<Stat> asianCupMatches;
  final List<Stat> goldCupMatches;
  final List<Stat> africanFootballLeagueMatches;
  final List<Stat> afcChampionsLeagueMatches;
  final List<Stat> afcCupMatches;
  final List<Stat> cafChampionsLeagueMatches;
  final List<Stat> cafConfederationCupMatches;
  final List<Stat> africanNationsChampionshipMatches;
  final List<Stat> spainSegundaDivisionMatches;
  final List<Stat> southAfricaPremierSoccerLeagueMatches;
  final List<Stat> italySerieBMatches;
  final List<Stat> serieCMatches;
  final List<Stat> turkeyLig1Matches;
  final List<Stat> friendlyMatches;
  final List<Stat> qatarStarsLeagueMatches;
  final List<Stat> belgiumChallengerProLeagueMatches;
  final List<Stat> netherlandsEersteDivisieMatches;
  final List<Stat> portugalLigaPortugalMatches;
  final List<Stat> germanyBundesliga2Matches;
  final List<Stat> germanyLiga3Matches;
  final List<Stat> franceLigue2Matches;
  final List<Stat> championnatNationalMatches;
  final List<Stat> brazilSerieAMatches;
  final List<Stat> brazilSerieBMatches;
  final List<Stat> brazilSerieCMatches;
  final List<Stat> ligaProfesionalArgentinaMatches;
  final List<Stat> argentinaPrimeraNacionalMatches;
  final List<Stat> copaArgentinaMatches;
  final List<Stat> usaMajorLeagueSoccerMatches;
  final List<Stat> uslChampionshipMatches;
  final List<Stat> uslLeagueOneMatches;
  final List<Stat> egyptPremierLeagueMatches;
  final List<Stat> ghanaPremierLeagueMatches;
  final List<Stat> scotlandChampionshipMatches;
  final List<Stat> todaysMatches; // Add this new field
  final int? currentLeagueId;

  @override
  List<Object?> get props => [
        status,
        fixtureListStatus,
        listOfLeagueFixtures,
        // ... other fields
      ];

  ContentState copyWith(
      {List<TableItem>? Content,
      ContentStatus? status,
      ContentStatus? fixtureListStatus,
      Map<String, List<List<TableItem>>>? nestedList,
      ContentStatus? currentPage,
      List<Stat>? leagueFixtures,
      int? leagueId,
      String? season,
      List<Stat>? premierLeagueMatches,
      List<Stat>? saudiLeagueMatches,
      List<Stat>? championsLeagueMatches,
      List<Stat>? ethioLeagueMatches,
      List<Stat>? laligaMatches,
      List<Stat>? league1Matches,
      List<Stat>? sereaMatches,
      List<Stat>? europaLeagueMatches,
      List<Stat>? facupMatches,
      List<Stat>? carabaoMatches,
      List<Stat>? african_wc_qualification,
      List<Stat>? european_wc_qualification,
      List<Stat>? asian_wc_qualification,
      List<Stat>? north_american_wc_qualification,
      List<Stat>? south_american_wc_qualification,
      List<Stat>? oceania_wc_qualification,
      List<Stat>? englishLeagueoneMatches,
      List<Stat>? englishLeagueTwoMatches,
      List<Stat>? englishChampionshipMatches,
      List<Stat>? europaNationsLeagueMatches,
      List<Stat>? europeanCupMatches,
      List<Stat>? africanCupMatches,
      List<Stat>? jupileProLeagueMatches,
      List<Stat>? eredivisieMatches,
      List<Stat>? premieraLigaMatches,
      List<Stat>? premiershipMatches,
      List<Stat>? premierSoccerLeagueMatches,
      List<Stat>? turkLeagueMatches,
      LeagueFixtures? listOfLeagueFixtures,
      List<Stat>? otherMatches,
      List<Stat>? bundesLigaMatches,
      List<Stat>? copaAmericaMatches,
      List<Stat>? olympicsmenmatchs,
      List<Stat>? asianCupMatches,
      List<Stat>? goldCupMatches,
      List<Stat>? africanFootballLeagueMatches,
      List<Stat>? afcChampionsLeagueMatches,
      List<Stat>? afcCupMatches,
      List<Stat>? cafChampionsLeagueMatches,
      List<Stat>? cafConfederationCupMatches,
      List<Stat>? africanNationsChampionshipMatches,
      List<Stat>? spainSegundaDivisionMatches,
      List<Stat>? southAfricaPremierSoccerLeagueMatches,
      List<Stat>? italySerieBMatches,
      List<Stat>? serieCMatches,
      List<Stat>? turkeyLig1Matches,
      List<Stat>? friendlyMatches,
      List<Stat>? qatarStarsLeagueMatches,
      List<Stat>? belgiumChallengerProLeagueMatches,
      List<Stat>? netherlandsEersteDivisieMatches,
      List<Stat>? portugalLigaPortugalMatches,
      List<Stat>? germanyBundesliga2Matches,
      List<Stat>? germanyLiga3Matches,
      List<Stat>? franceLigue2Matches,
      List<Stat>? championnatNationalMatches,
      List<Stat>? brazilSerieAMatches,
      List<Stat>? brazilSerieBMatches,
      List<Stat>? brazilSerieCMatches,
      List<Stat>? ligaProfesionalArgentinaMatches,
      List<Stat>? argentinaPrimeraNacionalMatches,
      List<Stat>? copaArgentinaMatches,
      List<Stat>? usaMajorLeagueSoccerMatches,
      List<Stat>? uslChampionshipMatches,
      List<Stat>? uslLeagueOneMatches,
      List<Stat>? egyptPremierLeagueMatches,
      List<Stat>? ghanaPremierLeagueMatches,
      List<Stat>? scotlandChampionshipMatches,
      List<Stat>? todaysMatches, // Add this parameter
      String? errorMessage,
      int? currentLeagueId}) {
    return ContentState(
        copaAmericaMatches: copaAmericaMatches ?? this.copaAmericaMatches,
        olympicsmenmatchs: olympicsmenmatchs ?? this.olympicsmenmatchs,
        asianCupMatches: asianCupMatches ?? this.asianCupMatches,
        goldCupMatches: goldCupMatches ?? this.goldCupMatches,
        africanFootballLeagueMatches:
            africanFootballLeagueMatches ?? this.africanFootballLeagueMatches,
        afcChampionsLeagueMatches:
            afcChampionsLeagueMatches ?? this.afcChampionsLeagueMatches,
        afcCupMatches: afcCupMatches ?? this.afcCupMatches,
        cafChampionsLeagueMatches:
            cafChampionsLeagueMatches ?? this.cafChampionsLeagueMatches,
        cafConfederationCupMatches:
            cafConfederationCupMatches ?? this.cafConfederationCupMatches,
        africanNationsChampionshipMatches: africanNationsChampionshipMatches ??
            this.africanNationsChampionshipMatches,
        spainSegundaDivisionMatches:
            spainSegundaDivisionMatches ?? this.spainSegundaDivisionMatches,
        southAfricaPremierSoccerLeagueMatches:
            southAfricaPremierSoccerLeagueMatches ??
                this.southAfricaPremierSoccerLeagueMatches,
        italySerieBMatches: italySerieBMatches ?? this.italySerieBMatches,
        serieCMatches: serieCMatches ?? this.serieCMatches,
        turkeyLig1Matches: turkeyLig1Matches ?? this.turkeyLig1Matches,
        friendlyMatches: friendlyMatches ?? this.friendlyMatches,
        qatarStarsLeagueMatches:
            qatarStarsLeagueMatches ?? this.qatarStarsLeagueMatches,
        belgiumChallengerProLeagueMatches: belgiumChallengerProLeagueMatches ??
            this.belgiumChallengerProLeagueMatches,
        netherlandsEersteDivisieMatches: netherlandsEersteDivisieMatches ??
            this.netherlandsEersteDivisieMatches,
        portugalLigaPortugalMatches:
            portugalLigaPortugalMatches ?? this.portugalLigaPortugalMatches,
        germanyBundesliga2Matches:
            germanyBundesliga2Matches ?? this.germanyBundesliga2Matches,
        germanyLiga3Matches: germanyLiga3Matches ?? this.germanyLiga3Matches,
        franceLigue2Matches: franceLigue2Matches ?? this.franceLigue2Matches,
        championnatNationalMatches:
            championnatNationalMatches ?? this.championnatNationalMatches,
        brazilSerieAMatches: brazilSerieAMatches ?? this.brazilSerieAMatches,
        brazilSerieBMatches: brazilSerieBMatches ?? this.brazilSerieBMatches,
        brazilSerieCMatches: brazilSerieCMatches ?? this.brazilSerieCMatches,
        ligaProfesionalArgentinaMatches: ligaProfesionalArgentinaMatches ??
            this.ligaProfesionalArgentinaMatches,
        argentinaPrimeraNacionalMatches: argentinaPrimeraNacionalMatches ??
            this.argentinaPrimeraNacionalMatches,
        copaArgentinaMatches: copaArgentinaMatches ?? this.copaArgentinaMatches,
        usaMajorLeagueSoccerMatches:
            usaMajorLeagueSoccerMatches ?? this.usaMajorLeagueSoccerMatches,
        uslChampionshipMatches:
            uslChampionshipMatches ?? this.uslChampionshipMatches,
        uslLeagueOneMatches: uslLeagueOneMatches ?? this.uslLeagueOneMatches,
        egyptPremierLeagueMatches:
            egyptPremierLeagueMatches ?? this.egyptPremierLeagueMatches,
        ghanaPremierLeagueMatches:
            ghanaPremierLeagueMatches ?? this.ghanaPremierLeagueMatches,
        scotlandChampionshipMatches:
            scotlandChampionshipMatches ?? this.scotlandChampionshipMatches,
        todaysMatches: todaysMatches ?? this.todaysMatches, // Add this field
        Content: Content ?? this.Content,
        status: status ?? this.status,
        nestedList: nestedList ?? this.nestedList,
        currentPage: currentPage ?? this.currentPage,
        leagueFixtures: leagueFixtures ?? this.leagueFixtures,
        leagueId: leagueId ?? this.leagueId,
        season: season ?? this.season,
        premierLeagueMatches: premierLeagueMatches ?? this.premierLeagueMatches,
        saudiLeagueMatches: saudiLeagueMatches ?? this.saudiLeagueMatches,
        championsLeagueMatches:
            championsLeagueMatches ?? this.championsLeagueMatches,
        ethioLeagueMatches: ethioLeagueMatches ?? this.ethioLeagueMatches,
        laligaMatches: laligaMatches ?? this.laligaMatches,
        league1Matches: league1Matches ?? this.league1Matches,
        sereaMatches: sereaMatches ?? this.sereaMatches,
        europaLeagueMatches: europaLeagueMatches ?? this.europaLeagueMatches,
        facupMatches: facupMatches ?? this.facupMatches,
        carabaoMatches: carabaoMatches ?? this.carabaoMatches,
        african_wc_qualification:
            african_wc_qualification ?? this.african_wc_qualification,
        european_wc_qualification:
            european_wc_qualification ?? this.european_wc_qualification,
        asian_wc_qualification:
            asian_wc_qualification ?? this.asian_wc_qualification,
        north_american_wc_qualification: north_american_wc_qualification ??
            this.north_american_wc_qualification,
        south_american_wc_qualification: south_american_wc_qualification ??
            this.south_american_wc_qualification,
        oceania_wc_qualification:
            oceania_wc_qualification ?? this.oceania_wc_qualification,
        englishLeagueoneMatches:
            englishLeagueoneMatches ?? this.englishLeagueoneMatches,
        englishLeagueTwoMatches:
            englishLeagueTwoMatches ?? this.englishLeagueTwoMatches,
        englishChampionshipMatches:
            englishChampionshipMatches ?? this.englishChampionshipMatches,
        europaNationsLeagueMatches:
            europaNationsLeagueMatches ?? this.europaNationsLeagueMatches,
        europeanCupMatches: europeanCupMatches ?? this.europeanCupMatches,
        africanCupMatches: africanCupMatches ?? this.africanCupMatches,
        jupileProLeagueMatches:
            jupileProLeagueMatches ?? this.jupileProLeagueMatches,
        eredivisieMatches: eredivisieMatches ?? this.eredivisieMatches,
        premieraLigaMatches: premieraLigaMatches ?? this.premieraLigaMatches,
        premiershipMatches: premiershipMatches ?? this.premiershipMatches,
        premierSoccerLeagueMatches:
            premierSoccerLeagueMatches ?? this.premierSoccerLeagueMatches,
        turkLeagueMatches: turkLeagueMatches ?? this.turkLeagueMatches,
        listOfLeagueFixtures: listOfLeagueFixtures ?? this.listOfLeagueFixtures,
        otherMatches: otherMatches ?? this.otherMatches,
        bundesLigaMatches: bundesLigaMatches ?? this.bundesLigaMatches,
        fixtureListStatus: fixtureListStatus ?? this.fixtureListStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        currentLeagueId: currentLeagueId ?? this.currentLeagueId);
  }
}
