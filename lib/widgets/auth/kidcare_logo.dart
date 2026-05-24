import 'package:flutter/material.dart';
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
        Container(
          padding: EdgeInsets.all(iconSize * 0.35),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: iconSize,
          ),
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
