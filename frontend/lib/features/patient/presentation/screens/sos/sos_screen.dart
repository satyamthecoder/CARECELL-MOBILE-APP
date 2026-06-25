import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  final _repo = PatientRepository();
  bool _triggering = false;
  bool _triggered = false;
  Map<String, dynamic>? _result;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Future<void> _trigger() async {
    setState(() => _triggering = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      double lat = 0, lng = 0;
      if (serviceEnabled && permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude; lng = pos.longitude;
      }
      final r = await _repo.triggerSos(lat, lng);
      setState(() {
        _triggering = false;
        if (r.isSuccess) { _triggered = true; _result = r.data; }
      });
    } catch (e) {
      setState(() => _triggering = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not trigger SOS. Check location permissions.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emergency,
      appBar: AppBar(
        backgroundColor: AppColors.emergency, elevation: 0,
        leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
        title: const Text('Emergency SOS', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (!_triggered) ...[
              const Text('Tap the button below to alert\nyour emergency contacts immediately',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _triggering ? null : _trigger,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (c, child) => Container(
                    width: 180 + (_pulseCtrl.value * 20), height: 180 + (_pulseCtrl.value * 20),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                    child: Center(
                      child: Container(
                        width: 150, height: 150,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: _triggering
                          ? const CircularProgressIndicator(color: AppColors.emergency)
                          : const Icon(Icons.sos, size: 64, color: AppColors.emergency),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text('SOS is always accessible, even from\nyour lock screen shortcut',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              const Text('Alert Sent!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('${_result?['contactsAlerted'] ?? 0} emergency contact(s) have been notified with your location',
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                onPressed: () => context.pop(),
                child: const Text('Done'),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
