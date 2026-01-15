import 'package:ai_stock_analyzer/Screens/auth/Signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const OTPVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  }) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  Timer? _timer;
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 Starting OTP verification...');
      
      // Create PhoneAuthCredential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: otp,
      );

      print('🔐 Signing in with credential...');
      
      // Sign in with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('✅ Sign in successful!');
      print('✅ User ID: ${userCredential.user?.uid}');
      print('✅ Phone: ${userCredential.user?.phoneNumber}');
      
      if (userCredential.user != null) {
        // Force reload to ensure token is fresh
        await userCredential.user!.reload();
        
        // Get the current user again
        User? currentUser = _auth.currentUser;
        
        if (currentUser != null) {
          print('✅ Current user confirmed: ${currentUser.uid}');
          
          // Check if user exists in Firestore
          print('🔍 Checking Firestore for user profile...');
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            print('✅ User profile exists in Firestore');
            
            if (mounted) {
              // User exists, navigate to home
              print('🏠 Navigating to home page...');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationPage()),
                (route) => false,
              );
            }
          } else {
            print('⚠️ User profile not found, navigating to signup...');
            
            if (mounted) {
              // User doesn't exist, navigate to signup
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupPage(
                    phoneNumber: widget.phoneNumber,
                    userId: currentUser.uid,
                  ),
                ),
              );
            }
          }
        } else {
          print('❌ Current user is null after reload');
          setState(() => _isLoading = false);
          _showError('Authentication failed. Please try again.');
        }
      } else {
        print('❌ User credential is null');
        setState(() => _isLoading = false);
        _showError('Authentication failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      setState(() => _isLoading = false);
      
      if (e.code == 'invalid-verification-code') {
        _showError('Invalid OTP. Please try again.');
      } else if (e.code == 'session-expired') {
        _showError('OTP expired. Please request a new one.');
      } else {
        _showError('Verification failed: ${e.message}');
      }
    } catch (e) {
      print('❌ Error during verification: $e');
      setState(() => _isLoading = false);
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    setState(() => _isResending = true);

    try {
      print('🔄 Resending OTP...');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: widget.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          setState(() => _isResending = false);
          _showError('Failed to resend OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP resent successfully');
          setState(() {
            _currentVerificationId = verificationId;
            _isResending = false;
          });
          _showSuccess('OTP sent successfully');
          _startResendTimer();
          
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto retrieval timeout');
        },
      );
    } catch (e) {
      print('❌ Error resending OTP: $e');
      setState(() => _isResending = false);
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a code to ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto-verify when all fields are filled
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Resend OTP
              Center(
                child: _isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _resendTimer > 0
                        ? Text(
                            'Resend OTP in ${_resendTimer}s',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          )
                        : TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}