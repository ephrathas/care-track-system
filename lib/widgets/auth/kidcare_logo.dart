import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/auth_assets.dart';
import '../../core/theme/app_theme.dart';

class KidCareLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? color;

  const KidCareLogo({
    super.key,
    this.iconSize = 28,
    this.fontSize = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTheme.primaryBlue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AuthAssets.logoMark,
          width: iconSize * 1.75,
          height: iconSize * 1.75,
        ),
        const SizedBox(width: 10),
        Text(
          'KidCare',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
