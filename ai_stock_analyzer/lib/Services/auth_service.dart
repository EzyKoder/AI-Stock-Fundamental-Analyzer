import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  // Replace with your actual backend URL.
  static const String baseUrl = 'http://172.20.10.8:5000/api'; // e.g. http://localhost:5000/api  
  
  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      print("Sending otp${baseUrl}/send-otp");
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP and check if user exists
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {
        'success': false,
        'message': 'Failed to verify OTP',
      };
    } catch (e) {
      print('Error verifying OTP: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Create new user in Firebase
  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] ?? false) {
          // Save login session
          await saveLoginSession(userData['phoneNumber']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Save login session
  Future<void> saveLoginSession(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setBool('isLoggedIn', true);
  }

  // Clear login session (logout)
  Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneNumber');
    await prefs.setBool('isLoggedIn', false);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Get logged in user phone number
  Future<String?> getLoggedInUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber');
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String phoneNumber) async {
    try {
      print("Searchingn user data");
      final response = await http.get(
        Uri.parse('$baseUrl/user/$phoneNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}