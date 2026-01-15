import 'dart:convert';
import 'package:http/http.dart' as http;

 class Predictions{


static Future<Map<String, dynamic>> predictStock({
  required String sector,
  required Map<String, dynamic> fundamentals,
}) async {
      print("prediction for sector: $sector with fundamentals: ${fundamentals.toString()}");

  final String baseUrl = "http://192.168.0.103:5000";
  final Uri url = Uri.parse("$baseUrl/predict/$sector");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(fundamentals),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Prediction failed: ${response.statusCode} - ${response.body}",
      );
    }
  } catch (e) {
    throw Exception("API Error: $e");
  }
}


}