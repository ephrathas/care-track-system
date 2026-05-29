import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

/// Shows product photo: local JPEG (if downloaded) → network URL → bundled SVG.
class ProductImage extends StatelessWidget {
  final String assetPath;
  final String? networkUrl;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final Color? accent;

  const ProductImage({
    super.key,
    required this.assetPath,
    this.networkUrl,
    this.height,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.accent,
  });

  String get _jpegPath => assetPath.replaceAll('.svg', '.jpg');

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width,
        child: Image.asset(
          _jpegPath,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildNetworkOrSvg(),
        ),
      ),
    );

    if (height == null && width == null) return child;
    return child;
  }

  Widget _buildNetworkOrSvg() {
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loadingPlaceholder();
        },
        errorBuilder: (_, __, ___) => _buildSvg(),
      );
    }
    return _buildSvg();
  }

  Widget _buildSvg() {
    return SvgPicture.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      placeholderBuilder: (_) => _loadingPlaceholder(),
    );
  }

  Widget _loadingPlaceholder() {
    final color = accent ?? AppTheme.primaryBlue;
    return Container(
      color: color.withOpacity(0.08),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: color.withOpacity(0.5), size: 32),
    );
  }
}
