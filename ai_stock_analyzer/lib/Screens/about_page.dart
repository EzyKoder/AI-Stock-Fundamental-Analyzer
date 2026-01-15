import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'About',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D8FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: 60,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI Stock Analyzer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Card
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
                      const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'About the App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Stock Analyzer is an intelligent platform that leverages advanced machine learning and artificial intelligence to analyze Indian stock market fundamentals. Our system evaluates 47+ fundamental parameters to provide data-driven investment recommendations.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Features Card
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
                      const Icon(Icons.star_outline, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(Icons.psychology, 'AI-Powered Analysis', 'Advanced ML algorithms for accurate predictions'),
                  _buildFeatureItem(Icons.analytics, 'Fundamental Analysis', '47+ parameters evaluated for each stock'),
                  _buildFeatureItem(Icons.trending_up, 'Upside Potential', 'Calculate potential returns based on fundamentals'),
                  _buildFeatureItem(Icons.compare_arrows, 'Stock Comparison', 'Compare multiple stocks side-by-side'),
                  _buildFeatureItem(Icons.category, 'Sector Analysis', 'Browse stocks by industry sectors'),
                  _buildFeatureItem(Icons.lightbulb_outline, 'AI Explanations', 'Understand why AI makes each recommendation'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Team Card
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
                      const Icon(Icons.group_outlined, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Development Team',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Group Terna A16',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A dedicated student team passionate about combining AI/ML with financial analysis to empower investors with data-driven insights.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Technology Card
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
                      const Icon(Icons.code, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Technologies Used',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip('Flutter'),
                      _buildTechChip('Python'),
                      _buildTechChip('Machine Learning'),
                      _buildTechChip('TensorFlow'),
                      _buildTechChip('scikit-learn'),
                      _buildTechChip('Firebase'),
                      _buildTechChip('REST API'),
                      _buildTechChip('LLM Integration'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 24),
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
                          'This app provides AI-generated analysis for educational and informational purposes only. It is not financial advice. Always consult with certified financial advisors before making investment decisions. Past performance does not guarantee future results.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add email functionality
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Contact Us'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add feedback functionality
                    },
                    icon: const Icon(Icons.feedback_outlined),
                    label: const Text('Feedback'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      foregroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2025 Majorchu Team. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }
}