import 'package:agriflock/features/auth/quiz/shared/vet_terms_dialog.dart';
import 'package:flutter/material.dart';

class TermsUtil {
  static Future<bool> showVetTermsDialog(
      BuildContext context, {
        bool showDeclineButton = true,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VetTermsDialog(
        onTermsResponse: (accepted) {
          Navigator.of(context).pop(accepted);
        },
        showDeclineButton: showDeclineButton,
      ),
    );

    return result ?? false;
  }
}