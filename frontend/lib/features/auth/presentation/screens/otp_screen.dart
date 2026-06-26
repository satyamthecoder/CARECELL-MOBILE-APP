/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final String nextRoute;
  const OtpScreen({super.key, required this.mobile, required this.nextRoute});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _repo = AuthRepository();
  String _otp = '';
  bool _loading = false, _resending = false;

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    setState(() => _loading = true);
    final r = await _repo.verifyOtp(widget.mobile, _otp);
    setState(() => _loading = false);
    if (!mounted) return;
    if (r.isSuccess) {
      context.go(widget.nextRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? 'Invalid OTP')));
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    await _repo.sendOtp(widget.mobile);
    setState(() => _resending = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = PinTheme(
      width: 54, height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 1.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Mobile'), leading: BackButton(onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(children: [
          const SizedBox(height: 40),
          const Icon(Icons.sms_outlined, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text('OTP sent to +91 ${widget.mobile}', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Enter the 6-digit code below', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Pinput(
            length: 6,
            defaultPinTheme: theme,
            focusedPinTheme: theme.copyDecorationWith(border: Border.all(color: AppColors.primary, width: 2)),
            onChanged: (v) => setState(() => _otp = v),
            onCompleted: (_) => _verify(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (_loading || _otp.length != 6) ? null : _verify,
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Verify OTP'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _resending ? null : _resend,
            child: _resending ? const Text('Resending...') : const Text("Didn't receive? Resend OTP"),
          ),
        ]),
      ),
    );
  }
}
*/



// new code with some chanes 

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final String nextRoute;

  const OtpScreen({
    super.key,
    required this.mobile,
    required this.nextRoute,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _repo = AuthRepository();

  String _otp = '';

  bool _loading = false;
  bool _resending = false;

  Future<void> _verify() async {
    if (_otp.length != 6) return;

    setState(() => _loading = true);

    final r = await _repo.verifyOtp(widget.mobile, _otp);

    if (!mounted) return;

    setState(() => _loading = false);

    if (r.isSuccess) {
      context.go(widget.nextRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r.error ?? 'Invalid OTP'),
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);

    await _repo.sendOtp(widget.mobile);

    if (!mounted) return;

    setState(() => _resending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Mobile'),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(
              Icons.sms_outlined,
              size: 64,
              color: AppColors.primary,
            ),

            const SizedBox(height: 24),

            Text(
              'OTP sent to +91 ${widget.mobile}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Enter the 6-digit code below',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "Enter OTP",
                counterText: "",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_loading || _otp.length != 6) ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Verify OTP"),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: _resending ? null : _resend,
              child: _resending
                  ? const Text("Resending...")
                  : const Text("Didn't receive? Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}