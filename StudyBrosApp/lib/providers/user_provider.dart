import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class UserProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  User _user = User();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final savedUser = await _hiveService.getUser();
      if (savedUser != null) {
        _user = savedUser;
      } else {
        // Save default user if none exists
        await _hiveService.saveUser(_user);
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      _user = updatedUser;
      await _hiveService.saveUser(_user);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
