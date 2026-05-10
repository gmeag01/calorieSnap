import 'package:flutter/material.dart';

class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final isOver = current > target;
    final barColor = isOver ? Colors.red[400]! : Colors.green[500]!;
    final bgColor = isOver ? Colors.red[100]! : Colors.green[100]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레이블 + 수치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  if (isOver)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.red),
                    ),
                  Text(
                    '${_fmt(current)} / ${_fmt(target)} $unit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOver ? Colors.red[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 프로그레스 바
          Stack(
            children: [
              // 배경
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // 진행
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),

          if (isOver) ...[
            const SizedBox(height: 5),
            Text(
              '목표치를 초과했습니다 (+${_fmt(current - target)} $unit)',
              style: TextStyle(fontSize: 11, color: Colors.red[400]),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
