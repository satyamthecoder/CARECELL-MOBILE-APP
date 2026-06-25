import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class SchemeFinderScreen extends StatefulWidget {
  const SchemeFinderScreen({super.key});
  @override
  State<SchemeFinderScreen> createState() => _SchemeFinderScreenState();
}

class _SchemeFinderScreenState extends State<SchemeFinderScreen> {
  final _repo = PatientRepository();
  List<dynamic> _schemes = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getSchemes();
    setState(() { _loading = false; if (r.isSuccess) _schemes = r.data ?? []; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Scheme Finder'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: _schemes.length,
            itemBuilder: (c, i) {
              final s = _schemes[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.policy_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    ]),
                    const SizedBox(height: 8),
                    Text(s['description'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Flexible(child: Text(s['eligibility'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.success))),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => launchUrl(Uri.parse(s['link'] ?? '')),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('Learn More'),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
    );
  }
}
