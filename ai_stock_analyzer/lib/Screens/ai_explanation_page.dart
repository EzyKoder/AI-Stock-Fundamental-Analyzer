import 'package:flutter/material.dart';

class AIExplanationPage extends StatelessWidget {
  final String symbol;
  final String prediction;

  const AIExplanationPage({
    Key? key,
    required this.symbol,
    required this.prediction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock AI explanation - In production, this will come from LLM API
    final String aiExplanation = '''
Our AI model has analyzed $symbol using advanced machine learning algorithms and fundamental analysis. Here's what we found:

**Strong Financial Position**
The company shows robust financial health with consistent revenue growth of 12.4% year-over-year. The profit margins remain healthy at 7.2%, indicating efficient operations and good cost management.

**Valuation Analysis**
With a P/E ratio of 24.56, the stock is reasonably valued compared to its sector peers. The current market cap of ₹16.6 Lakh Crores reflects strong investor confidence.

**Growth Indicators**
Return on Equity (ROE) stands at 9.8%, demonstrating effective use of shareholder equity. The debt-to-equity ratio of 0.52 indicates a balanced capital structure with manageable debt levels.

**Market Sentiment**
Based on technical indicators, institutional buying patterns, and sector performance, our model predicts a positive outlook with an upside potential of 23.5%.

**Risk Assessment**
While the fundamentals are strong, investors should monitor quarterly earnings, sector-specific challenges, and macroeconomic factors that could impact performance.

**Recommendation: $prediction**
Our AI assigns this rating based on comprehensive analysis of 47+ fundamental parameters, historical data patterns, and predictive modeling. This stock shows strong potential for medium to long-term investment.
    ''';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Analysis',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D8FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For $symbol',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Explanation Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange[400],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Understanding the Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    aiExplanation,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disclaimer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This analysis is generated by AI for informational purposes only. It should not be considered as financial advice. Please consult with a certified financial advisor before making investment decisions.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}