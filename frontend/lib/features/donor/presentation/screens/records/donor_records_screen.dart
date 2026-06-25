import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/donor_repository.dart';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart' show AppEndpoints;

class DonorRecordsScreen extends StatefulWidget {
  const DonorRecordsScreen({super.key});
  @override
  State<DonorRecordsScreen> createState() => _DonorRecordsScreenState();
}

class _DonorRecordsScreenState extends State<DonorRecordsScreen> {
  List<dynamic> _records = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await ApiClient().dio.get('${AppEndpoints.donorRecords}?page=0&size=20');
      setState(() { _loading = false; _records = r.data['data']['content'] ?? []; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'BLOOD_TEST': return Icons.bloodtype_outlined;
      case 'HLA_REPORT': return Icons.science_outlined;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records'), leading: BackButton(onPressed: () => context.pop())),
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
                const Text('No medical records uploaded', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Text('Upload your HLA report or blood test results', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
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
                      subtitle: Text('${rec['recordType'] ?? ''}'),
                      trailing: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
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
          const Text('Upload Medical Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.science_outlined), title: const Text('HLA Report'), onTap: () => Navigator.pop(c)),
          ListTile(leading: const Icon(Icons.bloodtype_outlined), title: const Text('Blood Test'), onTap: () => Navigator.pop(c)),
          ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('Other PDF'), onTap: () => Navigator.pop(c)),
        ]),
      ),
    );
  }
}
