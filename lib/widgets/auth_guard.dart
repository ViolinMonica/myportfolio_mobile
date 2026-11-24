import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Ensures the user is authenticated, pushing [LoginScreen] when needed.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return loggedIn ?? false;
}
