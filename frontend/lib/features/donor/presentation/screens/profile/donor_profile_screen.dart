import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/donor_repository.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});
  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _repo = DonorRepository();
  Map<String, dynamic>? _card;
  final _occupation = TextEditingController();
  final _address = TextEditingController();
  bool _loading = true, _saving = false, _consent = false;
  List<String> _selectedTypes = [];
  final _allTypes = ['WHOLE_BLOOD', 'PLATELETS', 'PLASMA', 'STEM_CELL', 'BONE_MARROW'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cardR = await _repo.getDonorCard();
    final profR = await _repo.getProfile();
    setState(() {
      _loading = false;
      if (cardR.isSuccess) _card = cardR.data;
      if (profR.isSuccess && profR.data != null) {
        _occupation.text = profR.data!['occupation'] ?? '';
        _address.text = profR.data!['address'] ?? '';
        _consent = profR.data!['donationConsentGiven'] == true;
        _selectedTypes = List<String>.from((profR.data!['donationTypes'] as List?)?.map((e) => e.toString()) ?? []);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final r = await _repo.updateProfile({
      'occupation': _occupation.text.trim(),
      'address': _address.text.trim(),
      'donationTypes': _selectedTypes,
      'donationConsentGiven': _consent,
    });
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.isSuccess ? 'Profile updated!' : (r.error ?? 'Failed'))));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donor Profile'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Donor card
          if (_card != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB71C1C), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              ),
              child: Column(children: [
                Row(children: const [
                  Icon(Icons.bloodtype, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text('DONOR CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ]),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: QrImageView(data: _card!['qrData'] ?? '', size: 130)),
                const SizedBox(height: 14),
                Text(_card!['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Blood Group: ${_card!['bloodGroup'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                Text('Total Donations: ${_card!['totalDonations'] ?? 0}', style: const TextStyle(color: Colors.white70)),
              ]),
            ),
          const SizedBox(height: 24),
          Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: _occupation, decoration: const InputDecoration(labelText: 'Occupation', prefixIcon: Icon(Icons.work_outline))),
          const SizedBox(height: 12),
          TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined))),
          const SizedBox(height: 16),
          Text('Donation Types', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _allTypes.map((t) {
            final sel = _selectedTypes.contains(t);
            return FilterChip(
              label: Text(t.replaceAll('_', ' ')),
              selected: sel,
              onSelected: (v) => setState(() => v ? _selectedTypes.add(t) : _selectedTypes.remove(t)),
              selectedColor: AppColors.primary.withOpacity(0.2),
            );
          }).toList()),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _consent, onChanged: (v) => setState(() => _consent = v ?? false),
            title: const Text('I consent to being matched for blood/organ donation requests', style: TextStyle(fontSize: 13)),
            contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
