import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _repo = AuthRepository();
  final _mobile = TextEditingController();
  final _otp = TextEditingController();
  final _newPass = TextEditingController();
  bool _loading = false, _otpSent = false, _obscure = true;

  Future<void> _sendOtp() async {
    if (_mobile.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final r = await _repo.forgotPassword(_mobile.text.trim());
    setState(() { _loading = false; if (r.isSuccess) _otpSent = true; });
    if (!mounted) return;
    if (!r.isSuccess) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? 'Failed')));
  }

  Future<void> _resetPassword() async {
    if (_otp.text.length != 6 || _newPass.text.length < 8) return;
    setState(() => _loading = true);
    final r = await _repo.resetPassword(_mobile.text.trim(), _otp.text.trim(), _newPass.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (r.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset! Please login.')));
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            enabled: !_otpSent,
            decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 16),
          if (!_otpSent)
            ElevatedButton(onPressed: _loading ? null : _sendOtp, child: const Text('Send OTP')),
          if (_otpSent) ...[
            TextFormField(controller: _otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '6-Digit OTP', prefixIcon: Icon(Icons.sms_outlined))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPass, obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'New Password', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loading ? null : _resetPassword, child: const Text('Reset Password')),
          ],
        ]),
      ),
    );
  }
}
