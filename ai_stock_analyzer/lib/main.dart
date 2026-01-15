import 'package:ai_stock_analyzer/Screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/compare_stocks_page.dart';
import 'screens/about_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const AIStockAnalyzerApp());
}

class AIStockAnalyzerApp extends StatelessWidget {
  const AIStockAnalyzerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Stock Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A5568)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF718096)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CompareStocksPage(),
    const MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows_rounded),
              label: 'Compare',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  User? _initialUser;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Get the current user immediately
    _initialUser = FirebaseAuth.instance.currentUser;
    
    print('🔐 Initial User Check: ${_initialUser?.uid}');
    print('🔐 Initial Phone: ${_initialUser?.phoneNumber}');

    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen
    if (_showSplash) {
      return const SplashScreen();
    }

    // After splash, use StreamBuilder for real-time auth updates
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // IMPORTANT: Use the initial user as the starting data
      initialData: _initialUser,
      builder: (context, snapshot) {
        print('🔐 Auth Stream - Connection: ${snapshot.connectionState}');
        print('🔐 Auth Stream - Has Data: ${snapshot.hasData}');
        print('🔐 Auth Stream - User: ${snapshot.data?.uid}');
        
        // Show loading only if we're waiting AND don't have initial data
        if (snapshot.connectionState == ConnectionState.waiting && 
            _initialUser == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            ),
          );
        }
        
        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User authenticated: ${snapshot.data!.uid}');
          return const MainNavigationPage();
        }
        
        // If user is not logged in
        print('❌ No user, showing login');
        return const LoginPage();
      },
    );
  }
}