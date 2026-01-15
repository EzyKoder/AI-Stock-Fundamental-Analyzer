import 'package:flutter/material.dart';

class PredictionBadgeWidget extends StatelessWidget {
  final String prediction;
  final bool compact;

  const PredictionBadgeWidget({
    Key? key,
    required this.prediction,
    this.compact = false,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (prediction) {
      case 'Strong Buy':
        return const Color(0xFF10B981);
      case 'Buy':
        return const Color(0xFF4ECDC4);
      case 'Neutral':
        return const Color(0xFFFFBE0B);
      case 'Sell':
        return Colors.orange[700]!;
      case 'Avoid':
        return const Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (prediction) {
      case 'Strong Buy':
        return Icons.trending_up;
      case 'Buy':
        return Icons.arrow_upward;
      case 'Hold':
        return Icons.remove;
      case 'Sell':
        return Icons.arrow_downward;
      case 'Avoid':
        return Icons.trending_down;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact 
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: compact ? 12 : 16,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            prediction,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}