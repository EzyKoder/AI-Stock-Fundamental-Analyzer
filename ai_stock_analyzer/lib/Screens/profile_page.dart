import 'package:ai_stock_analyzer/Screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current user
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Fetch user data from Firestore using UID
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'User profile not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo
                      Container(
                        width: double.infinity,
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
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                size: 48,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'AI Stock Analyzer',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // About the App
                      _buildDialogSection(
                        icon: Icons.info_outline,
                        title: 'About the App',
                        child: const Text(
                          'AI Stock Analyzer is an intelligent platform that leverages advanced machine learning and artificial intelligence to analyze Indian stock market fundamentals. Our system evaluates 47+ fundamental parameters to provide data-driven investment recommendations.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Key Features
                      _buildDialogSection(
                        icon: Icons.star_outline,
                        title: 'Key Features',
                        child: Column(
                          children: [
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

                      // Development Team
                      _buildDialogSection(
                        icon: Icons.group_outlined,
                        title: 'Development Team',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Group Terna A16',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A dedicated student team passionate about combining AI/ML with financial analysis to empower investors with data-driven insights.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Technologies Used
                      _buildDialogSection(
                        icon: Icons.code,
                        title: 'Technologies Used',
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildTechChip('Flutter'),
                            _buildTechChip('Dart'),
                            _buildTechChip('Python'),
                            _buildTechChip('FastAPI'),
                            _buildTechChip('Machine Learning'),
                            _buildTechChip('TensorFlow'),
                            _buildTechChip('scikit-learn'),
                            _buildTechChip('Pandas'),
                            _buildTechChip('NumPy'),
                            _buildTechChip('Firebase'),
                            _buildTechChip('REST API'),
                            _buildTechChip('LLM Integration'),
                            _buildTechChip('OpenAI API'),
                            _buildTechChip('Git'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Disclaimer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'This app provides AI-generated analysis for educational and informational purposes only. It is not financial advice. Always consult with certified financial advisors before making investment decisions. Past performance does not guarantee future results.',
                                    style: TextStyle(
                                      fontSize: 12,
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
                      const SizedBox(height: 16),

                      // Copyright
                      Center(
                        child: Text(
                          '© 2025-26 A16 Team. All rights reserved.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Sign out from Firebase
      await _auth.signOut();
      
      if (mounted) {
        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        // App Bar with gradient
        SliverAppBar(
          expandedHeight: 270,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF6C63FF),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF9D8FFF)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Profile Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          _getInitials(_userData?['name'] ?? 'U'),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userData?['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData?['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _userData?['phoneNumber'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: _showAboutDialog,
              tooltip: 'About',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadUserData,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Personal Information Card
                _buildSectionCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF6C63FF),
                  children: [
                    _buildInfoRow('Full Name', _userData?['name'] ?? 'N/A', Icons.person),
                    _buildDivider(),
                    _buildInfoRow('Email Address', _userData?['email'] ?? 'N/A', Icons.email),
                    _buildDivider(),
                    _buildInfoRow('Date of Birth', _userData?['dob'] ?? 'N/A', Icons.cake),
                    _buildDivider(),
                    _buildInfoRow('Gender', _userData?['gender'] ?? 'N/A', Icons.wc),
                    _buildDivider(),
                    _buildInfoRow('State', _userData?['state'] ?? 'N/A', Icons.location_on),
                  ],
                ),
                const SizedBox(height: 16),

                // Investment Profile Card
                _buildSectionCard(
                  title: 'Investment Profile',
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF4ECDC4),
                  children: [
                    _buildInfoRow('Occupation', _userData?['occupation'] ?? 'N/A', Icons.work),
                    _buildDivider(),
                    _buildInfoRow('Investment Experience', _userData?['investmentExperience'] ?? 'N/A', Icons.psychology),
                  ],
                ),
                const SizedBox(height: 16),

                // Account Information Card
                _buildSectionCard(
                  title: 'Account Information',
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFFFFBE0B),
                  children: [
                    _buildInfoRow('Member Since', _formatTimestamp(_userData?['createdAt']), Icons.event),
                    _buildDivider(),
                    _buildInfoRow('User ID', _auth.currentUser?.uid ?? 'N/A', Icons.fingerprint),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3748),
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

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      
      // Handle Firestore Timestamp
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } 
      // Handle String (ISO format)
      else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } 
      // Handle DateTime
      else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'N/A';
      }
      
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}