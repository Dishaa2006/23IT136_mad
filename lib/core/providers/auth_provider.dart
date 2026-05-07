import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  final box = Hive.box('settings');
  return AuthNotifier(box);
});

class AuthNotifier extends StateNotifier<String?> {
  final Box _box;

  AuthNotifier(this._box) : super(_box.get('username')) {
    if (state != null && state!.isEmpty) {
      state = null;
    }
  }

  void login(String username) {
    _box.put('username', username);
    state = username;
  }

  void logout() {
    _box.delete('username');
    state = null;
  }
}
