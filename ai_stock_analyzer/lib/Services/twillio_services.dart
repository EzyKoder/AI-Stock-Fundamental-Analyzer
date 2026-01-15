import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  final String baseUrl = "http://172.20.10.8:5000/api"; // e.g. https://twilio-verify.onrender.com

  Future<bool> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse("$baseUrl/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber}),
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyOtp(String phoneNumber, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber, "code": code}),
    );
    final body = jsonDecode(response.body);
    return body["success"] == true;
  }
}
