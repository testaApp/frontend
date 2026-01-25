import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../pages/constants/colors.dart';

Future<Color> generateDominantColor({required String? imageUrl}) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
          timeout: const Duration(seconds: 20),
          CachedNetworkImageProvider(
            imageUrl.toString(),
            errorListener: (error) => const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(
                'network problem',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          size: const Size(100, 100)); // Adjust the size as needed

  return paletteGenerator.dominantColor?.color ?? Colorscontainer.greenColor;
}
