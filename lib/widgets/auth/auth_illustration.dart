import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays an SVG auth illustration with a graceful icon fallback.
class AuthIllustration extends StatelessWidget {
  final String assetPath;
  final double height;
  final double? width;
  final BoxFit fit;
  final Widget? fallback;

  const AuthIllustration({
    super.key,
    required this.assetPath,
    this.height = 160,
    this.width,
    this.fit = BoxFit.contain,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: SvgPicture.asset(
        assetPath,
        fit: fit,
        placeholderBuilder: (_) => fallback ?? _defaultFallback(),
      ),
    );
  }

  Widget _defaultFallback() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: height * 0.25,
        color: Colors.grey.shade400,
      ),
    );
  }
}
