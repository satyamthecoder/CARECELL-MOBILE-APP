import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});
  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _repo = PatientRepository();
  final _occupation = TextEditingController();
  final _address = TextEditingController();
  final _conditions = TextEditingController();
  final _medications = TextEditingController();
  final _allergies = TextEditingController();
  bool _loading = true, _saving = false, _isCancerPatient = false, _needsTransplant = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getHealthProfile();
    if (r.isSuccess && r.data != null) {
      final d = r.data!;
      _occupation.text = d['occupation'] ?? '';
      _address.text = d['address'] ?? '';
      _conditions.text = (d['chronicConditions'] as List?)?.join(', ') ?? '';
      _medications.text = (d['currentMedications'] as List?)?.join(', ') ?? '';
      _allergies.text = (d['allergies'] as List?)?.join(', ') ?? '';
      _isCancerPatient = d['isCancerPatient'] == true;
      _needsTransplant = d['needsOrganTransplant'] == true;
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final r = await _repo.updateHealthProfile({
      'occupation': _occupation.text.trim(),
      'address': _address.text.trim(),
      'chronicConditions': _conditions.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'currentMedications': _medications.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'allergies': _allergies.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'isCancerPatient': _isCancerPatient,
      'needsOrganTransplant': _needsTransplant,
    });
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.isSuccess ? 'Profile updated!' : (r.error ?? 'Failed'))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Profile'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          TextField(controller: _occupation, decoration: const InputDecoration(labelText: 'Occupation', prefixIcon: Icon(Icons.work_outline))),
          const SizedBox(height: 12),
          TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined))),
          const SizedBox(height: 12),
          TextField(controller: _conditions, decoration: const InputDecoration(labelText: 'Chronic Conditions (comma separated)', prefixIcon: Icon(Icons.healing_outlined))),
          const SizedBox(height: 12),
          TextField(controller: _medications, decoration: const InputDecoration(labelText: 'Current Medications (comma separated)', prefixIcon: Icon(Icons.medication_outlined))),
          const SizedBox(height: 12),
          TextField(controller: _allergies, decoration: const InputDecoration(labelText: 'Allergies (comma separated)', prefixIcon: Icon(Icons.warning_amber_outlined))),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isCancerPatient, onChanged: (v) => setState(() => _isCancerPatient = v),
            title: const Text('Cancer Patient'), contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _needsTransplant, onChanged: (v) => setState(() => _needsTransplant = v),
            title: const Text('Needs Organ Transplant'), contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
