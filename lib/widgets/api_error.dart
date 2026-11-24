import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Shows [message] in a SnackBar, replacing the one currently shown.
void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Handles a failed write request the same way on every screen.
///
/// - **401**: the token was revoked or expired, so the session is cleared and
///   the login screen is opened again.
/// - **403**: the account is logged in but not the portfolio owner.
/// - **400**: DRF's first validation message is shown.
/// - **0**: the server could not be reached.
///
/// [action] completes the sentence "Gagal ...", e.g. `'menyimpan pengalaman'`.
Future<void> handleApiError(
  BuildContext context,
  ApiException error, {
  required String action,
}) async {
  switch (error.statusCode) {
    case 401:
      final auth = context.read<AuthState>();
      await auth.logout();
      if (!context.mounted) return;
      showSnack(context, 'Sesi berakhir, silakan login lagi.');
      await ensureLoggedIn(context);
    case 403:
      showSnack(context, 'Akun ini tidak punya izin untuk $action.');
    case 400:
      showSnack(context, 'Data ditolak server: ${error.readableMessage}');
    case 0:
      showSnack(context, error.message);
    default:
      showSnack(context, 'Gagal $action (${error.statusCode}).');
  }
}
