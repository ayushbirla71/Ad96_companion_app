import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Step indicator: 1 = Email, 2 = Verify OTP, 3 = Reset Password, 4 = Success
  int _currentStep = 1;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 6 discrete OTP digit controllers and focus nodes
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // Password visibility
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Loading state
  bool _isLoading = false;

  // Verified reset token
  String? _resetToken;

  // Resend Timer
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  // Password checklist state
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePasswordRules);
    _confirmPasswordController.addListener(_validatePasswordRules);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _validatePasswordRules() {
    final pass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = pass.length >= 8;
      _hasNumber = RegExp(r'\d').hasMatch(pass);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pass);
      _passwordsMatch = pass.isNotEmpty && pass == confirm;
    });
  }

  void _startResendTimer([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = seconds;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _resendCountdown = 0;
            _canResend = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
        }
      }
    });
  }

  String _getOtpString() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _otpControllers[i].text = digits[i];
      }
      final focusIndex = (digits.length >= 6) ? 5 : digits.length;
      _otpFocusNodes[focusIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Step 1: Send OTP ───────────────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showFeedback("Please enter your email address.", isError: true);
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showFeedback("Please enter a valid email address.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.sendForgotPasswordOtp(email);
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      _showFeedback(result["message"] ?? "Verification code sent to your email.");
      final cooldown = result["resendAfterSeconds"] is int
          ? result["resendAfterSeconds"] as int
          : 60;
      _startResendTimer(cooldown);
      setState(() => _currentStep = 2);

      // Focus first OTP box
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _otpFocusNodes.isNotEmpty) {
          _otpFocusNodes[0].requestFocus();
        }
      });
    } else {
      _showFeedback(result["message"] ?? "Failed to send verification code.", isError: true);
    }
  }

  // ── Step 2: Resend OTP ─────────────────────────────────────────────────────
  Future<void> _handleResendOtp() async {
    if (!_canResend || _isLoading) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    final result = await AuthService.sendForgotPasswordOtp(email);
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      _showFeedback("A fresh verification code has been dispatched.");
      for (final c in _otpControllers) {
        c.clear();
      }
      _startResendTimer(60);
      _otpFocusNodes[0].requestFocus();
    } else {
      _showFeedback(result["message"] ?? "Failed to resend code.", isError: true);
    }
  }

  // ── Step 2: Verify OTP ─────────────────────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    final otp = _getOtpString();
    if (otp.length < 6) {
      _showFeedback("Please enter the complete 6-digit code.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.verifyPasswordResetOtp(
      email: _emailController.text.trim(),
      otp: otp,
    );
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      _resetToken = result["resetToken"];
      _showFeedback("Code verified successfully!");
      setState(() => _currentStep = 3);
    } else {
      _showFeedback(result["message"] ?? "Invalid verification code.", isError: true);
    }
  }

  // ── Step 3: Reset Password ─────────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showFeedback("Please fill in both password fields.", isError: true);
      return;
    }

    if (!_hasMinLength || !_hasNumber || !_hasSpecialChar) {
      _showFeedback("Password does not meet the security requirements.", isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showFeedback("Passwords do not match.", isError: true);
      return;
    }

    if (_resetToken == null) {
      _showFeedback("Session expired. Please restart the reset process.", isError: true);
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.resetPassword(
      email: _emailController.text.trim(),
      resetToken: _resetToken!,
      newPassword: newPass,
      confirmPassword: confirmPass,
    );
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      setState(() => _currentStep = 4);
    } else {
      _showFeedback(result["message"] ?? "Failed to reset password.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
            ),
          ),

          // Glow Orbs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_currentStep == 2) {
                            setState(() => _currentStep = 1);
                          } else if (_currentStep == 3) {
                            setState(() => _currentStep = 2);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_currentStep < 4) _buildStepProgress(),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                // Scrollable Body
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 440),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCurrentStepContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator Pills ───────────────────────────────────────────────────
  Widget _buildStepProgress() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepDot(1, "Email"),
        _stepDivider(1),
        _stepDot(2, "Code"),
        _stepDivider(2),
        _stepDot(3, "Reset"),
      ],
    );
  }

  Widget _stepDot(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2563EB)
            : (isDone ? const Color(0xFF059669) : Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF60A5FA)
              : (isDone ? const Color(0xFF34D399) : Colors.transparent),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone)
            const Icon(Icons.check_rounded, color: Colors.white, size: 12)
          else
            Text(
              "$step",
              style: TextStyle(
                color: isActive || isDone ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive || isDone ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDivider(int step) {
    final isPassed = _currentStep > step;
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: isPassed ? const Color(0xFF059669) : Colors.white.withOpacity(0.12),
    );
  }

  // ── Switch Step Content ────────────────────────────────────────────────────
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Email();
      case 2:
        return _buildStep2Otp();
      case 3:
        return _buildStep3NewPassword();
      case 4:
        return _buildStep4Success();
      default:
        return _buildStep1Email();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 1: Enter Email
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep1Email() {
    return KeyedSubtree(
      key: const ValueKey("step1"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF60A5FA),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Center(
            child: Text(
              "Enter your registered email address. We'll send you a 6-digit verification code to reset your password.",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          // Email Field
          const Text(
            "Account Email",
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "e.g. user@company.com",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 20),
              filled: true,
              fillColor: const Color(0xFF0F172A).withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Send Verification Code",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Back to login
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF94A3B8)),
              label: const Text(
                "Back to Login",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 2: Verify 6-Digit OTP & Resend Timer
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep2Otp() {
    return KeyedSubtree(
      key: const ValueKey("step2"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.pin_outlined,
                color: Color(0xFF34D399),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Enter Verification Code",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "We have sent a 6-digit code to\n"),
                  TextSpan(
                    text: _emailController.text.trim(),
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          Center(
            child: GestureDetector(
              onTap: () => setState(() => _currentStep = 1),
              child: const Text(
                "Change email",
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 6 PIN Input Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _buildOtpDigitBox(index)),
          ),
          const SizedBox(height: 24),

          // Verify Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Verify Code",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend Timer Row
          Center(
            child: _canResend
                ? TextButton.icon(
                    onPressed: _isLoading ? null : _handleResendOtp,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF60A5FA)),
                    label: const Text(
                      "Resend Code",
                      style: TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF94A3B8), size: 15),
                      const SizedBox(width: 6),
                      Text(
                        "Resend code in 00:${_resendCountdown.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpDigitBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _otpControllers[index].text.isEmpty &&
              index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
            _otpControllers[index - 1].clear();
          }
        },
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: const Color(0xFF0F172A).withOpacity(0.6),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
          onChanged: (val) => _onOtpDigitChanged(val, index),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 3: Enter New Password & Complexity Checklist
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep3NewPassword() {
    return KeyedSubtree(
      key: const ValueKey("step3"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFFA78BFA),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Set New Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Center(
            child: Text(
              "Choose a strong password with at least 8 characters, numbers, and special symbols.",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // New Password Field
          const Text(
            "New Password",
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newPasswordController,
            obscureText: !_showNewPassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Enter new password",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _showNewPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
              ),
              filled: true,
              fillColor: const Color(0xFF0F172A).withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          const Text(
            "Confirm New Password",
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_showConfirmPassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Confirm new password",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF94A3B8), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              filled: true,
              fillColor: const Color(0xFF0F172A).withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Real-time Requirement Checklist
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Password Requirements",
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _requirementItem("At least 8 characters", _hasMinLength),
                const SizedBox(height: 6),
                _requirementItem("At least 1 numeric digit (0-9)", _hasNumber),
                const SizedBox(height: 6),
                _requirementItem("At least 1 special character (!@#\$%^&*)", _hasSpecialChar),
                const SizedBox(height: 6),
                _requirementItem("Passwords match", _passwordsMatch),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isMet ? const Color(0xFF10B981) : const Color(0xFF64748B),
          size: 15,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isMet ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 4: Success Screen
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep4Success() {
    return KeyedSubtree(
      key: const ValueKey("step4"),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF34D399),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Password Reset Complete!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          const Text(
            "Your password has been successfully updated. You can now use your new password to log in to your account.",
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                "Back to Login",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
