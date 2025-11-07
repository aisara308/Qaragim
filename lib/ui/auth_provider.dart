import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qaragim/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _email;
  String? _name;
  String? _birthday;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  String? get birthday => _birthday;

  Future<void> loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenFromPrefs = prefs.getString('token');
    if (tokenFromPrefs != null && tokenFromPrefs.isNotEmpty) {
      setToken(tokenFromPrefs);
    }
    notifyListeners();
  }

  Future<void> saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> clearTokenAndPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    clearToken();
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    if (_token == null) return false;

    try {
      final responce = await http.delete(
        Uri.parse(deleteaccount),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (responce.statusCode == 200) {
        await clearTokenAndPrefs();
        return true;
      } else {
        debugPrint('Delete failed: ${responce.statusCode} ${responce.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  void setToken(String token) async {
    _token = token;
    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      _email = decoded['email'];
      _name = decoded['name'];
      _birthday = decoded['birthday'];
    } catch (e) {
      _email = null;
      _name = null;
      _birthday = null;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    notifyListeners();
  }

  void setBirthday(String birthday) {
    _birthday = birthday;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void clearToken() {
    _email = null;
    _token = null;
    _name = null;
    _birthday = null;
    notifyListeners();
  }

  int? get age {
    if (_birthday == null) return null;

    try {
      final parts = _birthday!.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }
}
