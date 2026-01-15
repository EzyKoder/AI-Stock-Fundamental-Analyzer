import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/stock_card_widget.dart';
import 'stock_detail_page.dart';

class SectorWisePage extends StatefulWidget {
  final String? sectorName;
  final String? sectorDisplayName;
  final List<Map<String, dynamic>> sectors;

  const SectorWisePage({
    Key? key,
    this.sectorName,
    this.sectorDisplayName,
    required this.sectors,
  }) : super(key: key);

  @override
  State<SectorWisePage> createState() => _SectorWisePageState();
}

class _SectorWisePageState extends State<SectorWisePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _sectorStocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.sectorName != null) {
      _loadSectorStocks();
    } else {
      _loadAllSectorsData();
    }
  }

  Future<void> _loadSectorStocks() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(widget.sectorName!)
          .get();

      List<Map<String, dynamic>> stocks = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> stockData = doc.data() as Map<String, dynamic>;
        stocks.add({
          'documentId': doc.id,
          'data': stockData,
        });
      }

      setState(() {
        _sectorStocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sector stocks: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllSectorsData() async {
    setState(() => _isLoading = false);
  }

  String _getStockSymbol(Map<String, dynamic> stockData, String docId) {
    return stockData['symbol']?.toString() ?? 
           stockData['Symbol']?.toString() ?? 
           stockData['stock_symbol']?.toString() ?? 
           docId.toUpperCase();
  }

  String _getStockName(Map<String, dynamic> stockData, String docId) {
    return stockData['name']?.toString() ?? 
           stockData['company_name']?.toString() ?? 
           stockData['Company Name']?.toString() ?? 
           docId;
  }

  double _getStockPrice(Map<String, dynamic> stockData) {
    var price = stockData['current_price'] ?? 
                stockData['price'] ?? 
                stockData['Current Price'] ?? 
                stockData['ltp'] ?? 
                0.0;
    
    return (price is num) ? price.toDouble() : 0.0;
  }

 double _getChangePercent(Map<String, dynamic> stockData) {
    // Try to get change percent from various possible field names
    var change = (stockData['prev_day_close']!= null && stockData['current_price']!=null) ? 
                 ((stockData['current_price']-stockData['prev_day_close'])/stockData['prev_day_close']*100) :0.00;
                 
                 
    
    return (change is num) ? change.toDouble() : 0.0;
  }

  String _getPrediction(Map<String, dynamic> stockData) {
    return stockData['prediction']?.toString() ?? 
           stockData['recommendation']?.toString() ?? 
           stockData['ai_prediction']?.toString() ?? 
           'Hold';
  }

  Map<String, dynamic> _getSectorInfo() {
    return widget.sectors.firstWhere(
      (s) => s['name'] == widget.sectorName,
      orElse: () => {
        'name': widget.sectorName,
        'displayName': widget.sectorDisplayName ?? widget.sectorName,
        'icon': Icons.category,
        'color': const Color(0xFF6C63FF),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.sectorDisplayName ?? widget.sectorName ?? 'All Sectors',
          style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.sectorName != null
          ? _buildSectorStocks()
          : _buildAllSectors(),
    );
  }

  Widget _buildSectorStocks() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (_sectorStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No stocks available in this sector',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final sectorInfo = _getSectorInfo();
    final icon = sectorInfo['icon'] as IconData;
    final color = sectorInfo['color'] as Color;

    // Calculate sector statistics
    int strongBuyCount = 0;
    int buyCount = 0;
    int holdCount = 0;

    for (var stock in _sectorStocks) {
      String prediction = _getPrediction(stock['data']);
      if (prediction.toLowerCase().contains('strong buy')) {
        strongBuyCount++;
      } else if (prediction.toLowerCase().contains('buy')) {
        buyCount++;
      } else if (prediction.toLowerCase().contains('hold')) {
        holdCount++;
      }
    }

    return RefreshIndicator(
      onRefresh: _loadSectorStocks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Sector Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.sectorDisplayName ?? widget.sectorName!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_sectorStocks.length} stocks available',
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Sector Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSectorStat('Strong Buy', strongBuyCount.toString(), Colors.green),
                      _buildSectorStat('Buy', buyCount.toString(), const Color(0xFF4ECDC4)),
                      _buildSectorStat('Hold', holdCount.toString(), Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Stock List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stocks in this sector',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sectorStocks.length,
                    itemBuilder: (context, index) {
                      final stock = _sectorStocks[index];
                      final stockData = stock['data'] as Map<String, dynamic>;
                      final documentId = stock['documentId'] as String;

                      return StockCardWidget(
                        symbol: _getStockSymbol(stockData, documentId),
                        name: _getStockName(stockData, documentId),
                        price: _getStockPrice(stockData),
                        changePercent: _getChangePercent(stockData),
                        prediction: _getPrediction(stockData),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockDetailPage(
                                documentId: documentId,
                                sector: widget.sectorName!,
                              ),
                            ),
                          );
                        },
                      );
                    },
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

  Widget _buildAllSectors() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.sectors.length,
      itemBuilder: (context, index) {
        final sector = widget.sectors[index];
        final sectorName = sector['name'] as String;
        final displayName = sector['displayName'] as String;
        final icon = sector['icon'] as IconData;
        final color = sector['color'] as Color;
        
        return FutureBuilder<QuerySnapshot>(
          future: _firestore.collection(sectorName).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 140,
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
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final stocks = snapshot.data!.docs;
            
            // Calculate sector statistics
            int strongBuyCount = 0;
            int buyCount = 0;
            double totalChange = 0;
            
            for (var doc in stocks) {
              Map<String, dynamic> stockData = doc.data() as Map<String, dynamic>;
              String prediction = _getPrediction(stockData);
              double change = _getChangePercent(stockData);
              
              if (prediction.toLowerCase().contains('strong buy')) {
                strongBuyCount++;
              } else if (prediction.toLowerCase().contains('buy')) {
                buyCount++;
              }
              
              totalChange += change;
            }
            
            double avgChange = stocks.isEmpty ? 0.0 : totalChange / stocks.length;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                    ),
                    subtitle: Text(
                      '${stocks.length} stocks',
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectorWisePage(
                            sectorName: sectorName,
                            sectorDisplayName: displayName,
                            sectors: widget.sectors,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                          'Avg Change',
                          '${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(1)}%',
                          avgChange >= 0 ? Colors.green : Colors.red,
                        ),
                        _buildQuickStat(
                          'Top Picks',
                          '${strongBuyCount + buyCount}',
                          color,
                        ),
                        _buildQuickStat(
                          'Strong Buy',
                          strongBuyCount.toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectorStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}