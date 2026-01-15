import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreGaugeWidget extends StatelessWidget {
  final double score; // 0-100

  const ScoreGaugeWidget({
    Key? key,
    required this.score,
  }) : super(key: key);

  Color _getScoreColor() {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFF4ECDC4);
    if (score >= 30) return const Color(0xFFFFBE0B);
    return const Color(0xFFFF6B6B);
  }

  String _getScoreLabel() {
    if (score >= 75) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 30) return 'Moderate';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: GaugePainter(
              score: score,
              color: _getScoreColor(),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreLabel(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Low', const Color(0xFFFF6B6B)),
            const SizedBox(width: 16),
            _buildLegendItem('Moderate', const Color(0xFFFFBE0B)),
            const SizedBox(width: 16),
            _buildLegendItem('Good', const Color(0xFF4ECDC4)),
            const SizedBox(width: 16),
            _buildLegendItem('Excellent', const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}

class GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (score / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );

    // Score markers
    for (int i = 0; i <= 100; i += 25) {
      double angle = math.pi * 0.75 + (i / 100) * math.pi * 1.5;
      double x1 = center.dx + (radius - 10) * math.cos(angle);
      double y1 = center.dy + (radius - 10) * math.sin(angle);
      double x2 = center.dx + (radius + 10) * math.cos(angle);
      double y2 = center.dy + (radius + 10) * math.sin(angle);

      final markerPaint = Paint()
        ..color = Colors.grey[400]!
        ..strokeWidth = 2;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}