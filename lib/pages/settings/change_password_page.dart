import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'package:cms_app/services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _errorMsg;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPassword = _oldPassCtrl.text.trim();
    final newPassword = _newPassCtrl.text.trim();
    final confirmPassword = _confirmPassCtrl.text.trim();

    // Basic validation
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _errorMsg = 'New passwords do not match.');
      return;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$',
    );

    if (!passwordRegex.hasMatch(newPassword)) {
      setState(() {
        _errorMsg =
            'Password must be at least 8 characters long and include at least one number and one special character.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    try {
      final res = await ApiService.put('/user/change_passowrd', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      if (res.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password changed successfully'),
              backgroundColor: appColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        final json = jsonDecode(res.body);
        throw Exception(
          json['message']?.toString() ?? 'Server error ${res.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMsg = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accent, const Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: appColors.accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Keep your account secure',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Error banner ─────────────────────────────────────────
            if (_errorMsg != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appColors.redLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: appColors.red.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: appColors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: TextStyle(
                          color: appColors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _errorMsg = null),
                      child: Icon(
                        Icons.close_rounded,
                        color: appColors.red,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Form card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appColors.border),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current password
                  _fieldLabel('Current Password'),
                  const SizedBox(height: 6),
                  _passwordField(
                    ctrl: _oldPassCtrl,
                    hint: 'Enter current password',
                    obscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  const SizedBox(height: 20),

                  Divider(height: 1, color: appColors.borderLight),
                  const SizedBox(height: 20),

                  // New password
                  _fieldLabel('New Password'),
                  const SizedBox(height: 6),
                  _passwordField(
                    ctrl: _newPassCtrl,
                    hint: 'Enter new password',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 16),

                  // Confirm new password
                  _fieldLabel('Confirm New Password'),
                  const SizedBox(height: 6),
                  _passwordField(
                    ctrl: _confirmPassCtrl,
                    hint: 'Re-enter new password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Password hint ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: appColors.accentLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.accent.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: appColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Password must be at least 8 characters long and include at least one number and one special character.',
                      style: TextStyle(
                        color: appColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, size: 17),
                label: Text(_saving ? 'Updating…' : 'Change Password'),
                style: FilledButton.styleFrom(
                  backgroundColor: appColors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: appColors.accent.withOpacity(0.6),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      color: appColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    style: TextStyle(
      color: appColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: appColors.textMuted,
        size: 17,
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: appColors.textMuted,
          size: 17,
        ),
      ),
      filled: true,
      fillColor: appColors.surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.accent, width: 1.5),
      ),
    ),
  );
}
