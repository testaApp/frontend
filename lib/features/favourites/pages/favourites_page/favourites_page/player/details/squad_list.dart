import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class SquadList extends StatelessWidget {
  final List<PlayerName> players;
  final String header;
  final String? teamPic;

  const SquadList({
    super.key,
    required this.players,
    required this.header,
    this.teamPic,
  });

  String processPlayerName(String playerName) {
    return playerName.replaceAll('. ', '.\n').replaceAll(' ', '\n');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 130,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemCount: players.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final player = players[index];

          String deviceLanguage = localLanguageNotifier.value;
          String playerName = switch (deviceLanguage) {
            'am' || 'tr' => player.amharicName ?? '',
            'so' => player.somaliName ?? '',
            'or' => player.oromoName ?? '',
            _ => player.englishName ?? '',
          };

          String displayName = processPlayerName(playerName);
          List<String> nameParts = displayName.split('\n');
          bool hasTwoLines = nameParts.length > 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface.withOpacity(0.96),
                    scheme.surfaceVariant.withOpacity(0.86),
                  ],
                ),
                border: Border.all(
                  color: scheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 28,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary.withOpacity(0.7),
                                  scheme.tertiary.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                scheme.primary.withOpacity(0.6),
                                scheme.tertiary.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://media.api-sports.io/football/players/${player.id}.png',
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const SizedBox(),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nameParts[0],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtils.setTextStyle(
                                fontSize: hasTwoLines ? 12.5 : 12.5,
                                height: 1.05,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (hasTwoLines)
                              Text(
                                nameParts[1],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextUtils.setTextStyle(
                                  fontSize: 12.5,
                                  height: 1.05,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: scheme.surface,
                            border: Border.all(
                              color: scheme.primary.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            player.number != null ? '#${player.number}' : '-',
                            style: TextUtils.setTextStyle(
                              fontSize: 11.5,
                              height: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SquadList copyWith({List<PlayerName>? players, String? header}) {
    return SquadList(
      players: players ?? this.players,
      header: header ?? this.header,
    );
  }
}
