import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ----- HEADERS -----
  Future<Map<String, String>> _getHeaders({Map<String, String>? extra}) async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
    return headers;
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
    BuildContext context,
  ) async {
    final responce = await request();
    if (responce.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await request();
      } else {
        await _logout(context);
        throw Exception("Unauthorized");
      }
    }
    return responce;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('refreshToken');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  /// ----- GET -----
  Future<http.Response> get(
    String url,
    BuildContext context, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() async {
      final h = await _getHeaders(extra: headers);
      return http.get(Uri.parse(url), headers: h);
    }, context);
  }

  /// ----- POST ------
  Future<http.Response> post(
    String url,
    BuildContext context,
    Object body, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() async {
      final h = await _getHeaders(extra: headers);
      return http.post(Uri.parse(url), headers: h, body: jsonEncode(body));
    }, context);
  }

  /// ----- PUT -----
  Future<http.Response> put(
    String url,
    BuildContext context,
    Object body, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() async {
      final h = await _getHeaders(extra: headers);
      return http.put(Uri.parse(url), headers: h, body: jsonEncode(body));
    }, context);
  }

  /// ----- DELETE -----
  Future<http.Response> delete(
    String url,
    BuildContext context, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() async {
      final h = await _getHeaders(extra: headers);
      return http.delete(Uri.parse(url), headers: h);
    }, context);
  }

  Future<http.StreamedResponse> multipartRequest(
    String url,
    BuildContext context,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    final headers = await _getHeaders();
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 401) {
      final refreshed = await refreshToken();

      if (refreshed) {
        final newHeaders = await _getHeaders();
        request.headers.clear();
        request.headers.addAll(newHeaders);
        return await request.send();
      } else {
        await _logout(context);
        throw Exception("Unauthorized");
      }
    }

    return response;
  }

  /// ---------- PATCH ----------
  Future<http.Response> patch(
    String url,
    BuildContext context,
    Object body, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() async {
      final h = await _getHeaders(extra: headers);
      return http.patch(Uri.parse(url), headers: h, body: jsonEncode(body));
    }, context);
  }

  /// ----- REFRESH -----
  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final myRefreshToken = prefs.getString('refreshToken');

    if (myRefreshToken == null) return false;

    final response = await http.post(
      Uri.parse(refreshUserToken),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': myRefreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('token', data['token']);
      return true;
    }

    return false;
  }
}
