import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_search_page.dart';
import 'sector_wise_page.dart';
import 'stock_detail_page.dart';
import '../widgets/stock_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _featuredStocks = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> sectors = [
    {'name': 'banking', 'displayName': 'Banking', 'icon': Icons.account_balance, 'color': const Color(0xFF6C63FF)},
    {'name': 'it', 'displayName': 'IT', 'icon': Icons.computer, 'color': const Color(0xFF4ECDC4)},
    {'name': 'energy', 'displayName': 'Energy', 'icon': Icons.bolt, 'color': const Color(0xFFFFBE0B)},
   // {'name': 'pharma', 'displayName': 'Pharma', 'icon': Icons.medical_services, 'color': const Color(0xFFFF6B6B)},
    {'name': 'auto', 'displayName': 'Auto', 'icon': Icons.directions_car, 'color': const Color(0xFF95E1D3)},
    {'name': 'fmcg', 'displayName': 'FMCG', 'icon': Icons.shopping_cart, 'color': const Color(0xFFB57EDC)},
    {'name': 'metals', 'displayName': 'Metals', 'icon': Icons.factory, 'color': const Color(0xFFFF9F1C)},
    {'name': 'power', 'displayName': 'Power', 'icon': Icons.power, 'color': const Color(0xFF2EC4B6)},
    {'name': 'real_estate', 'displayName': 'Real Estate', 'icon': Icons.home_work, 'color': const Color(0xFFE63946)},
    {'name': 'telecom', 'displayName': 'Telecom', 'icon': Icons.cell_tower, 'color': const Color(0xFF457B9D)},
  ];

  @override
  void initState() {
    super.initState();
    _loadFeaturedStocks();
  }

  Future<void> _loadFeaturedStocks() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> allStocks = [];

      // Fetch stocks from all sectors (limit 2 per sector for variety)
      for (var sector in sectors) {
        QuerySnapshot snapshot = await _firestore
            .collection(sector['name'])
            .limit(2)
            .get();

        for (var doc in snapshot.docs) {
          Map<String, dynamic> stockData = doc.data() as Map<String, dynamic>;
          allStocks.add({
            'documentId': doc.id,
            'sector': sector['name'],
            'sectorDisplay': sector['displayName'],
            'data': stockData,
          });
        }
      }

      // Shuffle and take first 10 stocks for featured section
      allStocks.shuffle();
      setState(() {
        _featuredStocks = allStocks.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stocks: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getStockSymbol(Map<String, dynamic> stockData, String docId) {
    // Try to get symbol from various possible field names
    return stockData['symbol']?.toString() ?? 
           stockData['Symbol']?.toString() ?? 
           stockData['stock_symbol']?.toString() ?? 
           docId.toUpperCase();
  }

  String _getStockName(Map<String, dynamic> stockData, String docId) {
    // Try to get name from various possible field names
    return stockData['name']?.toString() ?? 
           stockData['company_name']?.toString() ?? 
           stockData['Company Name']?.toString() ?? 
           docId;
  }

  double _getStockPrice(Map<String, dynamic> stockData) {
    // Try to get price from various possible field names
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
    // Try to get prediction from various possible field names
    return stockData['prediction']?.toString() ?? 
           stockData['recommendation']?.toString() ?? 
           stockData['ai_prediction']?.toString() ?? 
           'Hold';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Stock Analyzer',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
            ),
            const Text(
              'Indian Market Analysis',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeaturedStocks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockSearchPage(sectors: sectors),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 12),
                        Text(
                          'Search stocks...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Sectors Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Browse by Sector', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SectorWisePage(sectors: sectors),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sectors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SectorWisePage(
                                sectorName: sectors[index]['name'],
                                sectorDisplayName: sectors[index]['displayName'],
                                sectors: sectors,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (sectors[index]['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  sectors[index]['icon'] as IconData,
                                  color: sectors[index]['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sectors[index]['displayName'] as String,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Featured Stocks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured Stocks', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18)),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _featuredStocks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No stocks available',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _featuredStocks.length,
                            itemBuilder: (context, index) {
                              final stock = _featuredStocks[index];
                              final stockData = stock['data'] as Map<String, dynamic>;
                              final documentId = stock['documentId'] as String;
                              final sector = stock['sector'] as String;

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
                                        sector: sector,
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
        ),
      ),
    );
  }
}