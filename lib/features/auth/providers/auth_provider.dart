import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient();

  String? _token;
  String? _fullName;
  String? _email;
  String? _role;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _token != null;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  bool get isStudent => _role == 'Student';
  bool get isCompany => _role == 'Company';
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _fullName = prefs.getString('fullName');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    _token = await _api.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
        'rememberMe': true,
      });

      final data = res.data['data'];
      _token = data['token'];
      _fullName = data['fullName'];
      _email = data['email'];
      _role = data['role'];

      await _api.saveToken(_token!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', _fullName ?? '');
      await prefs.setString('email', _email ?? '');
      await prefs.setString('role', _role ?? '');

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Giriş başarısız.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerStudent(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.dio.post(ApiConstants.registerStudent, data: data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Kayıt başarısız.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerCompany(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.dio.post(ApiConstants.registerCompany, data: data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Kayıt başarısız.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _fullName = null;
    _email = null;
    _role = null;
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
