import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _email;
  String? _name;
  String? _birthday;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  String? get birthday => _birthday;

  void setToken(String token) {
    _token = token;
    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      _email = decoded['email'];
    } catch (e) {
      _email = null;
    }
    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      _name = decoded['name'];
    } catch (e) {
      _name = null;
    }
    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      _birthday = decoded['birthday'];
    } catch (e) {
      _birthday = null;
    }
    notifyListeners();
  }

  void setBirthday(String birthday) {
    _birthday = birthday;
    notifyListeners();
  }

  void clearToken() {
    _email = null;
    _token = null;
    _name = null;
    _birthday = null;
    notifyListeners();
  }
}
