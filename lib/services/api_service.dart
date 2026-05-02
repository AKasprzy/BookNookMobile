import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
    static const String baseUrl = "http://10.0.2.2:8080/api";

  Future<dynamic> get(String endpoint, {String? token}) async {
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
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return _handle(response);
  }

  dynamic _handle(http.Response res) {
    final body = jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    } else {
      throw Exception(body.toString());
    }
  }
}