import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});
  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  final _repo = PatientRepository();
  List<dynamic> _treatments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getTreatments();
    setState(() { _loading = false; if (r.isSuccess) _treatments = r.data ?? []; });
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'ONGOING': return AppColors.info;
      case 'COMPLETED': return AppColors.success;
      case 'PAUSED': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treatment Tracker'), leading: BackButton(onPressed: () => context.pop())),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _treatments.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.medical_services_outlined, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('No active treatments', style: TextStyle(color: AppColors.textSecondary)),
              ]),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                itemCount: _treatments.length,
                itemBuilder: (c, i) {
                  final t = _treatments[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(t['treatmentName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Chip(label: Text(t['status'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: _statusColor(t['status'])),
                        ]),
                        const SizedBox(height: 4),
                        Text(t['condition'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(t['doctorName'] ?? 'No doctor assigned', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                          const SizedBox(width: 12),
                          const Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(child: Text(t['hospitalName'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textHint), overflow: TextOverflow.ellipsis)),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final condCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    final hospCtrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Add Treatment'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Treatment Name')),
          const SizedBox(height: 8),
          TextField(controller: condCtrl, decoration: const InputDecoration(labelText: 'Condition')),
          const SizedBox(height: 8),
          TextField(controller: docCtrl, decoration: const InputDecoration(labelText: 'Doctor Name')),
          const SizedBox(height: 8),
          TextField(controller: hospCtrl, decoration: const InputDecoration(labelText: 'Hospital Name')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          await _repo.addTreatment({
            'treatmentName': nameCtrl.text, 'condition': condCtrl.text,
            'doctorName': docCtrl.text, 'hospitalName': hospCtrl.text, 'status': 'ONGOING',
          });
          if (mounted) { Navigator.pop(c); _load(); }
        }, child: const Text('Add')),
      ],
    ));
  }
}
