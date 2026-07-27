import 'package:flutter/material.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';

class ScoreCircle extends StatelessWidget {
  final double score;
  final double size;
  final String? label;

  const ScoreCircle({
    super.key,
    required this.score,
    this.size = 120,
    this.label,
  });

  Color get _color => score >= 80
      ? AppColors.success
      : score >= 50
          ? AppColors.warning
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (_, value, __) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()}',
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.bold,
                    color: _color,
                  ),
                ),
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(fontSize: size * 0.1, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
