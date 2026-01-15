import 'package:flutter/material.dart';

class UpsideGraphWidget extends StatelessWidget {
  final double currentPrice;
  final double targetPrice;

  const UpsideGraphWidget({
    Key? key,
    required this.currentPrice,
    required this.targetPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double upsidePercent = ((targetPrice - currentPrice) / currentPrice) * 100;
    
    return Column(
      children: [
        // Price bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildPriceBar(
                'Current',
                currentPrice,
                const Color(0xFF6C63FF),
                currentPrice,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildPriceBar(
                'Target',
                targetPrice,
                const Color(0xFF10B981),
                currentPrice,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Upside potential indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 24),
              const SizedBox(width: 8),
              Text(
                'Upside Potential: +${upsidePercent.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Price range indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPricePoint('Current', currentPrice, const Color(0xFF6C63FF)),
            _buildPricePoint('Target', targetPrice, const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceBar(String label, double price, Color color, double maxPrice) {
    double height = (price / maxPrice) * 150;
    
    return Column(
      children: [
        Container(
          height: 180,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.6),
                  color,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricePoint(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '₹${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}