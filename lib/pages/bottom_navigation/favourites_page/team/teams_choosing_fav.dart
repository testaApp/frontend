import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../localization/demo_localization.dart';
import '../../../../main.dart';
import '../../../../util/auth/tokens.dart';
import '../../../../util/baseUrl.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
import '../../../entry_pages/team.dart';

class TeamsPage extends StatefulWidget {
  final Set<int> selectedTeamIDs;

  const TeamsPage({super.key, required this.selectedTeamIDs});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  int _selectedIndex = 0;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  final Map<String, List<FavTeamsData>> cache = {};
  late Set<int> selectedTeamIDs;

  final String url = BaseUrl().url;
  static const pageSize = 20;
  int currentPage = 1;
  bool hasMoreData = true;

  final List<String> leagueNames = [
    DemoLocalizations.ethiopia,
    DemoLocalizations.english,
    DemoLocalizations.spain,
    DemoLocalizations.italy,
    DemoLocalizations.germany,
    DemoLocalizations.france,
    DemoLocalizations.saudi,
    DemoLocalizations.southAfrica,
    DemoLocalizations.turkey,
    DemoLocalizations.egypt,
    DemoLocalizations.USA,
    DemoLocalizations.netherland,
    DemoLocalizations.belgium,
    DemoLocalizations.portugal,
    DemoLocalizations.scotland,
    DemoLocalizations.qatar,
  ];

  final List<String> leagueUrls = [
    '/api/favlistchoose/363',
    '/api/favlistchoose/39',
    '/api/favlistchoose/140',
    '/api/favlistchoose/135',
    '/api/favlistchoose/78',
    '/api/favlistchoose/61',
    '/api/favlistchoose/307',
    '/api/favlistchoose/288',
    '/api/favlistchoose/203',
    '/api/favlistchoose/233',
    '/api/favlistchoose/253',
    '/api/favlistchoose/88',
    '/api/favlistchoose/144',
    '/api/favlistchoose/94',
    '/api/favlistchoose/179',
    '/api/favlistchoose/305',
  ];

  @override
  void initState() {
    super.initState();
    selectedTeamIDs = Set.from(widget.selectedTeamIDs);

    _tabController = TabController(length: leagueNames.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);

    _loadTeams(refresh: true);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedIndex = _tabController.index;
        currentPage = 1;
        hasMoreData = true;
      });
      _loadTeams(refresh: true);
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMoreData) {
      _loadTeams();
    }
  }

  Future<void> _loadTeams({bool refresh = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (refresh) {
        hasError = false;
        errorMessage = '';
        cache.clear();
        currentPage = 1;
        hasMoreData = true;
      }
    });

    try {
      final newTeams = await fetchTeams(
          '$url${leagueUrls[_selectedIndex]}?page=$currentPage&limit=$pageSize');

      setState(() {
        final currentCache = cache[leagueUrls[_selectedIndex]] ?? [];
        final newUniqueTeams = newTeams.where(
            (newTeam) => !currentCache.any((e) => e.teamId == newTeam.teamId));

        cache[leagueUrls[_selectedIndex]] = [
          ...currentCache,
          ...newUniqueTeams
        ];

        hasMoreData = newTeams.length == pageSize;
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<List<FavTeamsData>> fetchTeams(String categoryUrl) async {
    try {
      final response = await http.get(
        Uri.parse(categoryUrl),
        headers: {
          'accesstoken': await getAccessToken(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> teamsList = [];

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          teamsList = jsonResponse[0] is List ? jsonResponse[0] : jsonResponse;
        }

        return teamsList.map((item) => FavTeamsData.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _toggleFavorite(int teamId) async {
    final wasSelected = selectedTeamIDs.contains(teamId);
    final endpoint = wasSelected
        ? '$url/api/user/removeFavTeam'
        : '$url/api/user/addToFavTeam';

    final response = await http.post(
      Uri.parse(endpoint),
      body: jsonEncode({'teamId': teamId.toString()}),
      headers: {
        'accesstoken': await getAccessToken(),
        'content-type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        wasSelected
            ? selectedTeamIDs.remove(teamId)
            : selectedTeamIDs.add(teamId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSelected
                ? "Team removed from favorites"
                : "Team added to favorites",
          ),
          backgroundColor: Colorscontainer.greenColor,
        ),
      );
    }
  }

  String _getLocalizedTeamName(FavTeamsData team) {
    switch (localLanguageNotifier.value) {
      case 'am':
      case 'tr':
        return team.Amharicname;
      case 'or':
        return team.Oromoname;
      case 'so':
        return team.Somaliname;
      default:
        return team.name;
    }
  }

  // ----------- MODERN UI ------------

  String apiFootballLogoUrl(int teamId) =>
      'https://media.api-sports.io/football/teams/$teamId.png'; // official URL for logos :contentReference[oaicite:1]{index=1}

  Widget _buildTeamListItem(FavTeamsData team) {
    final bool isSelected = selectedTeamIDs.contains(team.teamId);

    return Padding(
      key: ValueKey(team.teamId), // ← ensure stable identity
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: apiFootballLogoUrl(team.teamId),
              width: 42.w,
              height: 42.w,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 42.w,
                height: 42.w,
                color: Colors.grey[300],
              ),
              errorWidget: (_, __, ___) => Icon(
                Icons.shield_outlined,
                size: 28.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
          title: Text(
            _getLocalizedTeamName(team),
            style: TextUtils.setTextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              isSelected ? Icons.favorite : Icons.favorite_border,
              color: isSelected ? Colorscontainer.greenColor : Colors.grey[400],
            ),
            onPressed: () => _toggleFavorite(team.teamId),
          ),
          onTap: () => _toggleFavorite(team.teamId),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: [
          // Circle for team logo
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 12.w),
          // Column for team name placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Heart icon placeholder
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList(List<FavTeamsData> teams) {
    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 100.h),
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemCount: teams.length + (isLoading ? 3 : 0),
      itemBuilder: (_, index) {
        if (index < teams.length) return _buildTeamListItem(teams[index]);
        return _buildSkeletonItem();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false, // removes the back button
      title: null, // remove any title text
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(20.h),
        child: SizedBox(
          height: 40.h,
          child: ExtendedTabBar(
            controller: _tabController,
            isScrollable: true,
            physics: const BouncingScrollPhysics(),
            indicator: MaterialIndicator(
              topLeftRadius: 5.w,
              topRightRadius: 5.w,
              color: Colorscontainer.greenColor,
              strokeWidth: 2.w,
              horizontalPadding: 5.w,
            ),
            indicatorPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            indicatorColor: Colorscontainer.greenColor,
            indicatorWeight: 3,
            labelStyle: TextUtils.setTextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextUtils.setTextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.7),
              fontSize: 14.sp,
            ),
            tabs: leagueNames.asMap().entries.map((entry) {
              int index = entry.key;
              String name = entry.value;
              return _customTab(name, _selectedIndex == index);
            }).toList(),
          ),
        ),
      ),
    );
  }

// Custom tab widget remains the same
  Widget _customTab(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextUtils.setTextStyle(
          color: isSelected
              ? Colorscontainer.greenColor
              : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: Colorscontainer.greenColor,
        onRefresh: () => _loadTeams(refresh: true),
        child: hasError
            ? Center(child: Text(errorMessage))
            : TabBarView(
                controller: _tabController,
                children: leagueUrls
                    .map((e) => _buildTeamList(cache[e] ?? []))
                    .toList(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
