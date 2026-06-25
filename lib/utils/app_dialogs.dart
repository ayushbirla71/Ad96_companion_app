import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppDialogs {
  static void showValidationError(
    BuildContext context,
    AppColors appColors,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: appColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appColors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: appColors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Validation Error",
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          content: Text(
            message,
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text("OK"),
                style: FilledButton.styleFrom(
                  backgroundColor: appColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
