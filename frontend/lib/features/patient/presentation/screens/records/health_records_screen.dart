import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});
  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final _repo = PatientRepository();
  List<dynamic> _records = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getRecords();
    setState(() { _loading = false; if (r.isSuccess) _records = r.data ?? []; });
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'BLOOD_TEST': return Icons.bloodtype_outlined;
      case 'MRI': case 'CT_SCAN': case 'PET_SCAN': return Icons.medical_information_outlined;
      case 'PRESCRIPTION': return Icons.receipt_long_outlined;
      case 'VACCINATION': return Icons.vaccines_outlined;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadSheet,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _records.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.folder_off_outlined, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('No health records yet', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('Upload lab reports, prescriptions & scans', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ]),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                itemCount: _records.length,
                itemBuilder: (c, i) {
                  final rec = _records[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(_iconFor(rec['recordType']), color: AppColors.primary)),
                      title: Text(rec['originalFileName'] ?? 'Document', maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${rec['recordType'] ?? ''} • ${rec['hospitalName'] ?? 'Unknown'}'),
                      trailing: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Upload Health Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Take Photo'), onTap: () => Navigator.pop(c)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(c)),
          ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('Upload PDF'), onTap: () => Navigator.pop(c)),
          const SizedBox(height: 8),
          const Text('Supported: PDF, JPG, PNG (max 20MB)', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
        ]),
      ),
    );
  }
}
