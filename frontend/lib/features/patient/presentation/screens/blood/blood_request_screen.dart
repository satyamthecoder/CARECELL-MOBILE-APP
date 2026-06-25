import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});
  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _repo = PatientRepository();
  final _formKey = GlobalKey<FormState>();
  final _hospital = TextEditingController();
  final _city = TextEditingController();
  final _notes = TextEditingController();
  String? _bloodGroup, _donationType, _urgency = 'NORMAL';
  bool _loading = false;
  List<dynamic> _myRequests = [];

  final _bloodGroups = ['A_POSITIVE','A_NEGATIVE','B_POSITIVE','B_NEGATIVE','AB_POSITIVE','AB_NEGATIVE','O_POSITIVE','O_NEGATIVE'];
  final _displayMap = {'A_POSITIVE':'A+','A_NEGATIVE':'A-','B_POSITIVE':'B+','B_NEGATIVE':'B-','AB_POSITIVE':'AB+','AB_NEGATIVE':'AB-','O_POSITIVE':'O+','O_NEGATIVE':'O-'};
  final _donationTypes = ['WHOLE_BLOOD','PLATELETS','PLASMA'];

  @override
  void initState() { super.initState(); _loadRequests(); }

  Future<void> _loadRequests() async {
    final r = await _repo.getBloodRequests();
    if (r.isSuccess) setState(() => _myRequests = r.data ?? []);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final r = await _repo.createBloodRequest({
      'requiredBloodGroup': _bloodGroup,
      'donationType': _donationType,
      'hospitalName': _hospital.text.trim(),
      'hospitalCity': _city.text.trim(),
      'urgencyLevel': _urgency,
      'additionalNotes': _notes.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (r.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blood request created! Searching for donors...')));
      _hospital.clear(); _city.clear(); _notes.clear();
      setState(() { _bloodGroup = null; _donationType = null; });
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Donation Request'), leading: BackButton(onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(children: [
                  Text('Create Urgent Request', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _bloodGroup,
                    decoration: const InputDecoration(labelText: 'Blood Group Needed', prefixIcon: Icon(Icons.bloodtype_outlined)),
                    items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(_displayMap[b]!))).toList(),
                    onChanged: (v) => setState(() => _bloodGroup = v),
                    validator: (v) => v == null ? 'Select blood group' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _donationType,
                    decoration: const InputDecoration(labelText: 'Donation Type', prefixIcon: Icon(Icons.water_drop_outlined)),
                    items: _donationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ')))).toList(),
                    onChanged: (v) => setState(() => _donationType = v),
                    validator: (v) => v == null ? 'Select type' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _hospital, decoration: const InputDecoration(labelText: 'Hospital Name', prefixIcon: Icon(Icons.local_hospital_outlined)),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined)),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _urgency,
                    decoration: const InputDecoration(labelText: 'Urgency', prefixIcon: Icon(Icons.priority_high)),
                    items: ['CRITICAL','HIGH','NORMAL'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _urgency = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Additional Notes (optional)', prefixIcon: Icon(Icons.notes_outlined))),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.bloodRed),
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send Urgent Request'),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('My Requests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_myRequests.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No blood requests yet', style: TextStyle(color: AppColors.textSecondary))))
          else
            ..._myRequests.map((req) => Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.bloodRedLight, child: Text(_displayMap[req['requiredBloodGroup']] ?? '?', style: const TextStyle(color: AppColors.bloodRed, fontWeight: FontWeight.bold))),
                title: Text(req['hospitalName'] ?? ''),
                subtitle: Text('${req['donationType']} • ${req['status']}'),
                trailing: Chip(label: Text(req['urgencyLevel'] ?? '', style: const TextStyle(fontSize: 10)), backgroundColor: AppColors.warning.withOpacity(0.15)),
              ),
            )),
        ],
      ),
    );
  }
}
