import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../../domain/player/playerName.dart';
import '../../../../../../main.dart';
import '../../../../../constants/text_utils.dart';

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
    return SizedBox(
      height: 155, // compact height preserved
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // Add your tap logic here if needed
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image section (unchanged)
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://media.api-sports.io/football/players/${player.id}.png',
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const SizedBox(),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Name
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nameParts[0],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                              fontSize: hasTwoLines ? 13 : 13,
                              height: 1.05,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (hasTwoLines)
                            Text(
                              nameParts[1],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtils.setTextStyle(
                                fontSize: 13,
                                height: 1.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Number
                      Text(
                        player.number != null ? '#${player.number}' : '-',
                        style: TextUtils.setTextStyle(
                          fontSize: 12.5,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
