import 'package:flutter/material.dart';

class CompareStocksPage extends StatefulWidget {
  const CompareStocksPage({Key? key}) : super(key: key);

  @override
  State<CompareStocksPage> createState() => _CompareStocksPageState();
}

class _CompareStocksPageState extends State<CompareStocksPage> {
  String? selectedStock1;
  String? selectedStock2;

  // Mock stock data
  final List<String> availableStocks = ['RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'ICICIBANK', 'ITC'];

  final Map<String, Map<String, dynamic>> stockComparison = {
    'RELIANCE': {
      'price': 2456.75,
      'pe': 24.56,
      'marketCap': 16.6,
      'roe': 9.8,
      'debtToEquity': 0.52,
      'dividendYield': 0.35,
      'revenueGrowth': 12.4,
      'aiScore': 78.5,
    },
    'TCS': {
      'price': 3678.20,
      'pe': 28.34,
      'marketCap': 13.4,
      'roe': 42.5,
      'debtToEquity': 0.05,
      'dividendYield': 1.8,
      'revenueGrowth': 15.2,
      'aiScore': 82.0,
    },
    'HDFCBANK': {
      'price': 1632.45,
      'pe': 18.45,
      'marketCap': 9.2,
      'roe': 16.8,
      'debtToEquity': 0.0,
      'dividendYield': 1.2,
      'revenueGrowth': 18.7,
      'aiScore': 75.5,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Compare Stocks',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stock Selection Cards
            Row(
              children: [
                Expanded(child: _buildStockSelector(1)),
                const SizedBox(width: 12),
                const Icon(Icons.compare_arrows, color: Color(0xFF6C63FF), size: 32),
                const SizedBox(width: 12),
                Expanded(child: _buildStockSelector(2)),
              ],
            ),
            const SizedBox(height: 24),

            if (selectedStock1 != null && selectedStock2 != null) ...[
              // Comparison Charts
              _buildComparisonCard(
                'AI Confidence Score',
                Icons.psychology,
                selectedStock1!,
                selectedStock2!,
                stockComparison[selectedStock1]!['aiScore'],
                stockComparison[selectedStock2]!['aiScore'],
                isPercentage: false,
              ),
              const SizedBox(height: 16),
              _buildComparisonCard(
                'P/E Ratio',
                Icons.trending_up,
                selectedStock1!,
                selectedStock2!,
                stockComparison[selectedStock1]!['pe'],
                stockComparison[selectedStock2]!['pe'],
                isPercentage: false,
                lowerIsBetter: true,
              ),
              const SizedBox(height: 16),
              _buildComparisonCard(
                'Return on Equity',
                Icons.account_balance_wallet,
                selectedStock1!,
                selectedStock2!,
                stockComparison[selectedStock1]!['roe'],
                stockComparison[selectedStock2]!['roe'],
                isPercentage: true,
              ),
              const SizedBox(height: 16),
              _buildComparisonCard(
                'Revenue Growth',
                Icons.show_chart,
                selectedStock1!,
                selectedStock2!,
                stockComparison[selectedStock1]!['revenueGrowth'],
                stockComparison[selectedStock2]!['revenueGrowth'],
                isPercentage: true,
              ),
              const SizedBox(height: 24),

              // Comparison Table
              _buildComparisonTable(),
            ] else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSelector(int position) {
    String? selectedStock = position == 1 ? selectedStock1 : selectedStock2;
    return GestureDetector(
      onTap: () => _showStockPicker(position),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedStock != null ? const Color(0xFF6C63FF) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              selectedStock != null ? Icons.check_circle : Icons.add_circle_outline,
              color: selectedStock != null ? const Color(0xFF6C63FF) : Colors.grey[400],
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              selectedStock ?? 'Select Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedStock != null ? const Color(0xFF2D3748) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockPicker(int position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...availableStocks.map((stock) {
                return ListTile(
                  leading: const Icon(Icons.trending_up, color: Color(0xFF6C63FF)),
                  title: Text(stock),
                  onTap: () {
                    setState(() {
                      if (position == 1) {
                        selectedStock1 = stock;
                      } else {
                        selectedStock2 = stock;
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonCard(
    String title,
    IconData icon,
    String stock1,
    String stock2,
    double value1,
    double value2, {
    bool isPercentage = false,
    bool lowerIsBetter = false,
  }) {
    double maxValue = value1 > value2 ? value1 : value2;
    double bar1Width = (value1 / maxValue) * 100;
    double bar2Width = (value2 / maxValue) * 100;

    bool stock1Better = lowerIsBetter ? value1 < value2 : value1 > value2;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: const Color(0xFF6C63FF), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildComparisonBar(stock1, value1, bar1Width, stock1Better, isPercentage),
          const SizedBox(height: 12),
          _buildComparisonBar(stock2, value2, bar2Width, !stock1Better, isPercentage),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String stock, double value, double width, bool isBetter, bool isPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stock, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(
              '${value.toStringAsFixed(isPercentage ? 1 : 2)}${isPercentage ? '%' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: width / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isBetter ? const Color(0xFF4ECDC4) : const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Detailed Comparison',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
          ),
          const SizedBox(height: 16),
          _buildTableRow('Metric', selectedStock1!, selectedStock2!, isHeader: true),
          const Divider(),
          _buildTableRow('Price', '₹${stockComparison[selectedStock1]!['price']}', '₹${stockComparison[selectedStock2]!['price']}'),
          _buildTableRow('Market Cap', '₹${stockComparison[selectedStock1]!['marketCap']}L Cr', '₹${stockComparison[selectedStock2]!['marketCap']}L Cr'),
          _buildTableRow('Debt/Equity', '${stockComparison[selectedStock1]!['debtToEquity']}', '${stockComparison[selectedStock2]!['debtToEquity']}'),
          _buildTableRow('Dividend Yield', '${stockComparison[selectedStock1]!['dividendYield']}%', '${stockComparison[selectedStock2]!['dividendYield']}%'),
        ],
      ),
    );
  }

  Widget _buildTableRow(String metric, String value1, String value2, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? const Color(0xFF2D3748) : const Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Select Two Stocks to Compare',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose stocks from above to see detailed comparison',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}