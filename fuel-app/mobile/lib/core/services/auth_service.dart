import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _client = Supabase.instance.client;

  bool get isLoggedIn => _client.auth.currentUser != null;
  User? get currentUser => _client.auth.currentUser;

  AuthService() {
    _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final res = await _client.auth.signUp(email: email, password: senha);
      if (res.user != null) {
        await _client.from('usuarios').insert({
          'auth_id': res.user!.id,
          'nome': nome,
        });
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro inesperado';
    }
  }

  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: senha);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro inesperado';
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}