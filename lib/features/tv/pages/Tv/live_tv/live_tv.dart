import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/state/bloc/live_tv/live_tv_State.dart';
import 'package:blogapp/state/bloc/live_tv/live_tv_bloc.dart';
import 'package:blogapp/state/bloc/live_tv/live_tv_event.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/Live_Tv_model.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'live-other-card.dart';
import 'live-special-card.dart';

// Assumed existing
// ValueNotifier<String> localLanguageNotifier;

class LiveTv extends StatefulWidget {
  const LiveTv({super.key});

  @override
  State<LiveTv> createState() => _LiveTvState();
}

class _LiveTvState extends State<LiveTv> with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  Timer? _autoSlider;

  final _sportsScroll = ScrollController();
  final _newsScroll = ScrollController();
  final _userScroll = ScrollController();

  int _sportsPage = 1;
  int _newsPage = 1;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  // ---------------- LOCALIZATION ----------------
  String _t({
    required String en,
    required String am,
    required String or,
    required String ti,
    required String so,
  }) {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' => am,
      'or' => or,
      'ti' => ti,
      'so' => so,
      'en' => en,
      _ => en,
    };
  }

  // ---------------- LIFECYCLE ----------------
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: .82);
    _startAutoSlider();
    _fetchInitial();
  }

  void _startAutoSlider() {
    _autoSlider = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        final next = (_pageController.page?.round() ?? 0) + 1;
        _pageController.animateToPage(
          next % 10,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _fetchInitial() {
    if (_initialized) return;
    final bloc = context.read<LiveTvBloc>();
    bloc.add(LiveTvRequested());
    bloc.add(FetchSportsChannels(page: _sportsPage));
    bloc.add(FetchNewsChannels(page: _newsPage));
    bloc.add(LoadUserAddedChannels());
    _initialized = true;
  }

  @override
  void dispose() {
    _autoSlider?.cancel();
    _pageController.dispose();
    _sportsScroll.dispose();
    _newsScroll.dispose();
    _userScroll.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      floatingActionButton: _buildFab(),
      body: BlocConsumer<LiveTvBloc, LiveTvState>(
        listener: (context, state) {
          if (state.parsingError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.parsingError!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == LiveTvStatus.requested ||
              state.status == LiveTvStatus.parsing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == LiveTvStatus.networkFailure) {
            return _buildError();
          }

          return _buildContent(state);
        },
      ),
    );
  }

  // ---------------- FAB ----------------
  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Colorscontainer.greenColor,
      tooltip: _t(
        en: 'Add Channel',
        am: 'ቻናል ጨምር',
        or: 'Chaanaala Dabali',
        ti: 'ቻናል ወስኽ',
        so: 'Ku dar Kanaal',
      ),
      child: const Icon(Icons.add),
      onPressed: _showAddChannelSheet,
    );
  }

  // ---------------- ADD CHANNEL (ADVANCED) ----------------
  void _showAddChannelSheet() {
    final controller = TextEditingController();
    bool processing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _t(
                          en: 'Add Live TV Playlist',
                          am: 'የቀጥታ ቲቪ ዝርዝር ጨምር',
                          or: 'Tarree TV Kallattii Dabali',
                          ti: 'ዝርዝር ቲቪ ወስኽ',
                          so: 'Ku dar Liiska TV',
                        ),
                        style: TextUtils.setTextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.url,
                        enabled: !processing,
                        decoration: InputDecoration(
                          hintText: 'https://example.com/playlist.m3u',
                          filled: true,
                          fillColor: Colors.white.withOpacity(.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      processing
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colorscontainer.greenColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  final url = controller.text.trim();
                                  if (!_validUrl(url)) {
                                    _toast(
                                      _t(
                                        en: 'Invalid playlist URL',
                                        am: 'የተሳሳተ URL',
                                        or: 'URL dogoggoraa',
                                        ti: 'URL ዘይቅኑዕ',
                                        so: 'URL khaldan',
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => processing = true);

                                  context
                                      .read<LiveTvBloc>()
                                      .add(ParseM3ULink(url));

                                  Navigator.pop(context);

                                  _toast(
                                    _t(
                                      en: 'Parsing channels...',
                                      am: 'ቻናሎች በመተንተን ላይ...',
                                      or: 'Chaanaaloota qorachaa jira...',
                                      ti: 'ቻናላት ይተንተናሉ...',
                                      so: 'Kanaalada waa la falanqaynayaa...',
                                    ),
                                  );
                                },
                                child: Text(
                                  _t(
                                    en: 'Add',
                                    am: 'ጨምር',
                                    or: 'Dabali',
                                    ti: 'ወስኽ',
                                    so: 'Ku dar',
                                  ),
                                ),
                              ),
                            ),
                      //
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (url.endsWith('.m3u') || url.endsWith('.m3u8'));
    } catch (_) {
      return false;
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- CONTENT ----------------
  Widget _buildContent(LiveTvState state) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<LiveTvBloc>();
        bloc.add(LiveTvRequested());
        bloc.add(FetchSportsChannels(page: 1));
        bloc.add(FetchNewsChannels(page: 1));
        bloc.add(LoadUserAddedChannels());
        // Small delay to allow the UI to reflect the refresh
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          if (state.recentChannels.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 420.h,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.recentChannels.take(10).length,
                  itemBuilder: (_, i) {
                    final c = state.recentChannels[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: LiveSpecialCard(
                        logoUrl: c.tvgLogo,
                        channelName: c.title,
                        videoUrl: c.url,
                        groupTitle: c.groupTitle,
                      ),
                    );
                  },
                ),
              ),
            ),
          _section(
            _t(
              en: 'User Added',
              am: 'በተጠቃሚ የተጨመሩ',
              or: 'Fayyadamaan Dabalame',
              ti: 'ተጠቃሚ ዝወሰኹ',
              so: 'Isticmaale Ku Daray',
            ),
            state.userAddedChannels,
            _userScroll,
          ),
          _section(
            _t(
              en: 'Live Games',
              am: 'ቀጥታ ጨዋታዎች',
              or: 'Taphoota Kallattii',
              ti: 'ቀጥታ ጨዋታታት',
              so: 'Ciyaaro Toos ah',
            ),
            state.sportsChannels,
            _sportsScroll,
          ),
          _section(
            _t(
              en: 'News',
              am: 'ዜና',
              or: 'Oduu',
              ti: 'ዜና',
              so: 'Warar',
            ),
            state.newsChannels,
            _newsScroll,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<LivetvModel> channels,
    ScrollController controller,
  ) {
    if (channels.isEmpty) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Text(
              title,
              style: TextUtils.setTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 160.h,
            child: ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemCount: channels.length,
              itemBuilder: (_, i) {
                final c = channels[i];
                return LiveTvOtherCard(
                  image: c.tvgLogo != null
                      ? NetworkImage(c.tvgLogo!)
                      : const AssetImage('assets/testa_testa.png')
                          as ImageProvider,
                  title: c.title,
                  videoUrl: c.url,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ERROR ----------------
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            _t(
              en: 'Network Error',
              am: 'የኔትወርክ ችግኝ',
              or: 'Rakkoo Interneetii',
              ti: 'ግጉይ ኔትዎርክ',
              so: 'Cilad Shabakad',
            ),
          ),
        ],
      ),
    );
  }
}
