import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../patient/data/repositories/patient_repository.dart';

class HealthCardScreen extends StatefulWidget {
  const HealthCardScreen({super.key});
  @override
  State<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends State<HealthCardScreen> {
  final _repo = PatientRepository();
  Map<String, dynamic>? _card;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getHealthCard();
    setState(() { _loading = false; if (r.isSuccess) _card = r.data; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Health Card'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _card == null
          ? const Center(child: Text('Could not load health card'))
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(children: [
                  Row(children: const [
                    Icon(Icons.local_hospital, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('CareCell', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('HEALTH ID', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: QrImageView(data: _card!['qrData'] ?? '', size: 160),
                  ),
                  const SizedBox(height: 20),
                  Text(_card!['healthId'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _row('Name', _card!['name']),
                  _row('Age', '${_card!['age']}'),
                  _row('Gender', '${_card!['gender']}'),
                  _row('Blood Group', _card!['bloodGroup']),
                  _row('State', _card!['state']),
                ]),
              ),
            ),
    );
  }

  Widget _row(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      Text(value ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  );
}
