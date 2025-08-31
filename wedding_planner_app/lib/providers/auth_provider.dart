import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  static const String _storageKey = 'user_data';
  
  UserModel? _user;
  bool _isLoading = true;

  AuthProvider(this.prefs) {
    _loadUser();
  }

  bool get isLoggedIn => _user != null;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  void _loadUser() {
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        _user = UserModel.fromJson(raw);
      } catch (_) {
        _user = null;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({required String name, String? email, String? phone}) async {
    _isLoading = true;
    notifyListeners();

    final newUser = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      email: email?.isEmpty == true ? null : email,
      phone: phone?.isEmpty == true ? null : phone,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await prefs.setString(_storageKey, newUser.toJson());
    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await prefs.remove(_storageKey);
    _user = null;
    notifyListeners();
  }
}