import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_detail_page.dart';

class StockSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> sectors;

  const StockSearchPage({Key? key, required this.sectors}) : super(key: key);

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      List<Map<String, dynamic>> results = [];
      String searchQuery = query.toLowerCase();

      // Search across all sector collections
      for (var sector in widget.sectors) {
        QuerySnapshot snapshot = await _firestore
            .collection(sector['name'])
            .get();

        for (var doc in snapshot.docs) {
          Map<String, dynamic> stockData = doc.data() as Map<String, dynamic>;
          String documentId = doc.id;

          // Check if document ID or any stock field matches the search query
          bool matches = documentId.toLowerCase().contains(searchQuery) ||
                        _getStockSymbol(stockData, documentId).toLowerCase().contains(searchQuery) ||
                        _getStockName(stockData, documentId).toLowerCase().contains(searchQuery);

          if (matches) {
            results.add({
              'documentId': documentId,
              'sector': sector['name'],
              'sectorDisplay': sector['displayName'],
              'sectorColor': sector['color'],
              'data': stockData,
            });
          }
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching stocks: $e');
      setState(() {
        _isSearching = false;
      });
    }
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
    var change = stockData['change_percent'] ?? 
                 stockData['change'] ?? 
                 stockData['Change %'] ?? 
                 stockData['percent_change'] ?? 
                 0.0;
    
    return (change is num) ? change.toDouble() : 0.0;
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
        title: const Text(
          'Search Stocks',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by symbol or name...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  )
                : !_hasSearched
                    ? _buildEmptyState()
                    : _searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Search for stocks',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter symbol or company name',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 32),
                const SizedBox(height: 12),
                Text(
                  'Searching across ${widget.sectors.length} sectors',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No stocks found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Try searching with stock symbol like RELIANCE, TCS, INFY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        final stockData = stock['data'] as Map<String, dynamic>;
        final documentId = stock['documentId'] as String;
        final sector = stock['sector'] as String;
        final sectorDisplay = stock['sectorDisplay'] as String;
        final sectorColor = stock['sectorColor'] as Color;

        final symbol = _getStockSymbol(stockData, documentId);
        final name = _getStockName(stockData, documentId);
        final price = _getStockPrice(stockData);
        final changePercent = _getChangePercent(stockData);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: sectorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.trending_up, color: sectorColor),
            ),
            title: Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3748)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sectorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sectorDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: sectorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (price > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2D3748),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (changePercent != 0) ...[
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          Icon(
                            changePercent > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: changePercent > 0 ? Colors.green : Colors.red,
                          ),
                          Text(
                            '${changePercent.abs().toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: changePercent > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
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
          ),
        );
      },
    );
  }
}