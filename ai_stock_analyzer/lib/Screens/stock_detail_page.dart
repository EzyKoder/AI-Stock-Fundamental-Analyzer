import 'package:ai_stock_analyzer/Services/prediction.dart';
import 'package:ai_stock_analyzer/widgets/prediction_badge_widget.dart';
import 'package:ai_stock_analyzer/widgets/score_guage_widget.dart';
import 'package:ai_stock_analyzer/widgets/upside_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_explanation_page.dart';

class StockDetailPage extends StatefulWidget {
  final String documentId;
  final String sector;

  const StockDetailPage({
    Key? key,
    required this.documentId,
    required this.sector,
  }) : super(key: key);

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _stockData;
  Map<String, dynamic>? _predictionData;
  bool _isLoading = true;
  bool _isPredictionLoading = false;
  bool _hasPrediction = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      DocumentSnapshot doc = await _firestore
          .collection(widget.sector)
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        setState(() {
          _stockData = doc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
        
        // Check for existing prediction
        await _checkForTodaysPrediction();
      } else {
        setState(() {
          _error = 'Stock not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading stock: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkForTodaysPrediction() async {
    try {
      // Get today's date (start and end of day)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Query for today's prediction
      final predictionPath = 'predictions/${widget.sector}/${widget.documentId}';
      // Get current UTC time
      final nowUtc = DateTime.now().toUtc();

      // Define start and end of the UTC day
      final startOfDayUtc = DateTime.utc(
        nowUtc.year,
        nowUtc.month,
        nowUtc.day,
        0, 0, 0,
      );

      final endOfDayUtc = DateTime.utc(
        nowUtc.year,
        nowUtc.month,
        nowUtc.day,
        23, 59, 59,
      );

      print("Checking predictions for ${widget.documentId} in sector ${widget.sector} at ${predictionPath}-------------------------------");

      final querySnapshot = await _firestore
          .collection(predictionPath)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDayUtc.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endOfDayUtc.toIso8601String())
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      print("${querySnapshot.docs.length} predictions found for today.");

      if (querySnapshot.docs.isNotEmpty) {
        // Found today's prediction
        setState(() {
          _predictionData = querySnapshot.docs.first.data();
          _hasPrediction = true;
        });
      } else {
        // No prediction for today
        setState(() {
          _hasPrediction = false;
          _predictionData = null;
        });
      }
    } catch (e) {
      print('Error checking prediction: $e');
      setState(() {
        _hasPrediction = false;
        _predictionData = null;
      });
    }
  }

  Future<void> _generateNewPrediction(String sector) async {
    setState(() {
      _isPredictionLoading = true;
    });

    try {
      final result = await Predictions.predictStock(
        sector: sector,
        fundamentals: {
          ..._getFundamentals(),
          "Company": widget.documentId,
        },
      );
      
      setState(() {
        _predictionData = result;
        _hasPrediction = true;
        _isPredictionLoading = false;
      });
    } catch (e) {
      print('Error generating prediction: $e');
      setState(() {
        _isPredictionLoading = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating prediction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStockSymbol() {
    if (_stockData == null) return widget.documentId.toUpperCase();
    return _stockData!['symbol']?.toString() ?? 
           _stockData!['Symbol']?.toString() ?? 
           _stockData!['stock_symbol']?.toString() ?? 
           widget.documentId.toUpperCase();
  }

  String _getStockName() {
    if (_stockData == null) return widget.documentId;
    return _stockData!['name']?.toString() ?? 
           _stockData!['company_name']?.toString() ?? 
           _stockData!['Company Name']?.toString() ?? 
           widget.documentId;
  }

  double _getNumericValue(String key, {double defaultValue = 0.0}) {
    if (_stockData == null) return defaultValue;
    
    var value = _stockData![key];
    if (key == "change_percent") {
      value = (_stockData!['prev_day_close'] != null && _stockData!['current_price'] != null) ? 
                 ((_stockData!['current_price'] - _stockData!['prev_day_close']) / _stockData!['prev_day_close'] * 100) : 0.00;
    }
    if (value == null) return defaultValue;
    
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value.replaceAll(RegExp(r'[^0-9.-]'), ''));
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  String _getStringValue(String key, {String defaultValue = 'N/A'}) {
    if (_stockData == null) return defaultValue;
    return _stockData![key]?.toString() ?? defaultValue;
  }

  Map<String, dynamic> _getFundamentals() {
    if (_stockData == null) return {};
    
    final excludeKeys = [
      'symbol', 'Symbol', 'stock_symbol',
      'name', 'company_name', 'Company Name',
      'Closing_Price', 'price', 'Current Price', 'ltp', 'Closing_Price',
      'change_percent', 'change', 'Change %', 'percent_change',
      'prediction', 'recommendation', 'ai_prediction',
      'ai_score', 'aiScore', 'score', 'prev_day_close',
      'upside_potential', 'upsidePotential', 'target_price', 'targetPrice', 'updated_at', 'source'
    ];

    Map<String, dynamic> fundamentals = {};
    _stockData!.forEach((key, value) {
      if (!excludeKeys.contains(key) && value != null) {
        fundamentals[key] = value;
      }
    });

    return fundamentals;
  }

  String _formatFundamentalKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildNoPredictionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Prediction Not Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate today\'s AI-powered stock prediction and analysis',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _isPredictionLoading
                ? const Column(
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Analyzing stock data...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: () => _generateNewPrediction(widget.sector),
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: const Text(
                      'Generate AI Prediction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStockData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPrice = _getNumericValue('current_price') != 0
        ? _getNumericValue('current_price')
        : _getNumericValue('price') != 0
            ? _getNumericValue('price')
            : _getNumericValue('ltp', defaultValue: 0.0);

    final changePercent = _getNumericValue('change_percent') != 0
        ? _getNumericValue('change_percent')
        : _getNumericValue('change', defaultValue: 0.0);

    final fundamentals = _getFundamentals();

    // Only calculate these if we have prediction data
    String? prediction;
    double? upsidePotential;
    double? targetPrice;
    double? confidence;

    if (_hasPrediction && _predictionData != null) {
      switch (_predictionData!['direction']?.toString().toUpperCase()) {
        case '1':
          prediction = 'Neutral';
          break;
        case '2':
          prediction = 'Strong Buy';
          break;
        
        
        default:
          prediction = 'Avoid';
      }

      // prediction = _predictionData!['direction']?.toString().toUpperCase() ?? 'HOLD';
      upsidePotential = (_predictionData!['predicted_change_percent'] as num?)?.toDouble() ?? 0.0;
      targetPrice = (_predictionData!['predicted_price'] as num?)?.toDouble() ?? currentPrice;
      confidence = ((_predictionData!['confidence'] as num?)?.toDouble() ?? 0.75) * 100;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStockSymbol(),
              style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              _getStockName(),
              style: const TextStyle(color: Color(0xFF718096), fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Today', style: TextStyle(color: Color(0xFF9CA3AF))),
                      const SizedBox(width: 8),
                      Icon(
                        changePercent > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: changePercent > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${changePercent.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: changePercent > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('Prev Day Closing:', style: TextStyle(color: Color(0xFF9CA3AF))),
                      const SizedBox(width: 8),
                      Text(
                        '${_stockData!['prev_day_close']?.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Prediction Section - Show button if no prediction, else show full card
            if (!_hasPrediction)
              _buildNoPredictionCard()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Prediction',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          PredictionBadgeWidget(prediction: prediction!),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Upside Potential', 
                                style: TextStyle(color: Colors.white70, fontSize: 12)
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${upsidePotential! >= 0 ? '+' : ''}${upsidePotential.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: upsidePotential >= 0 ? Colors.lightGreenAccent : Colors.redAccent,
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(height: 50, width: 1, color: Colors.white30),
                          Column(
                            children: [
                              const Text('Target Price', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(
                                '₹${targetPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Updated: ${DateTime.parse(_predictionData!['timestamp']).toLocal().toString().split('.')[0]}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AIExplanationPage(
                                symbol: _getStockSymbol(),
                                prediction: prediction!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.psychology, size: 18),
                        label: const Text('View AI Explanation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),

            // AI Score Gauge - Only show if we have prediction
            if (_hasPrediction)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                        'AI Confidence Score',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 20),
                      ScoreGaugeWidget(score: confidence!),
                    ],
                  ),
                ),
              ),
            
            if (_hasPrediction) const SizedBox(height: 20),

            // Upside Potential Graph - Only show if we have prediction
            if (_hasPrediction)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                        'Price Projection',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 20),
                      UpsideGraphWidget(
                        currentPrice: currentPrice,
                        targetPrice: targetPrice!,
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_hasPrediction) const SizedBox(height: 20),

            // Fundamentals
            if (fundamentals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                        'Key Fundamentals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 16),
                      ...fundamentals.entries.map((entry) {
                        var v;
                        if (entry.key == "current_price") {
                          v = entry.value.toStringAsFixed(2);
                        } else {
                          v = entry.value.toString();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatFundamentalKey(entry.key),
                                  style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  v,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}