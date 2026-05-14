import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080/api";

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  Future<dynamic> get(String endpoint) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handle(response);
  }

  Future<dynamic> post(String endpoint, Map data) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return _handle(response);
  }

  dynamic _handle(http.Response res) {
    dynamic body;

    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw Exception("Invalid server response");
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    } else {
      if (body is Map && body.containsKey('message')) {
        throw Exception(body['message']);
      } else {
        throw Exception("Request failed (${res.statusCode})");
      }
    }
  }
}