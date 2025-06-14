import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _userType;

  /// ✅ Get Current User Type
  String? get userType => _userType;

  /// ✅ Load User Type from Storage (Auto Login)
  Future<void> loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    _userType = prefs.getString('userType');
    notifyListeners();
  }

  /// ✅ Login as Regular User
  Future<void> loginAsUser() async {
    _userType = 'user';
    await _saveUserType();
    notifyListeners();
  }

  /// ✅ Login as Admin
  Future<void> loginAsAdmin() async {
    _userType = 'admin';
    await _saveUserType();
    notifyListeners();
  }

  /// ✅ Logout & Clear Stored User Type
  Future<void> logout() async {
    _userType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    notifyListeners();
  }

  /// 🔒 Private Method: Save User Type Persistently
  Future<void> _saveUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', _userType!);
  }
}
