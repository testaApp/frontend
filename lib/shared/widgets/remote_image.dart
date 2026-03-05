import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget networkImageWithSvg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BaseCacheManager? cacheManager,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.trim().isEmpty) {
    return _defaultErrorWidget(
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
    );
  }

  if (url.toLowerCase().endsWith('.svg')) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => _defaultPlaceholder(
        width: width,
        height: height,
        placeholder: placeholder,
      ),
    );
  }

  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    cacheManager: cacheManager,
    placeholder: (_, __) => _defaultPlaceholder(
      width: width,
      height: height,
      placeholder: placeholder,
    ),
    errorWidget: (_, __, ___) => _defaultErrorWidget(
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
    ),
  );
}

Widget _defaultPlaceholder({
  double? width,
  double? height,
  Widget? placeholder,
}) {
  if (placeholder != null) return placeholder;
  return Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
  );
}

Widget _defaultErrorWidget({
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  if (errorWidget != null) return errorWidget;
  return Image.asset(
    'assets/testa_logo.png',
    width: width,
    height: height,
    fit: fit,
  );
}
