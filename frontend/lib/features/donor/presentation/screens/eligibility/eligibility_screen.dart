import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/donor_repository.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});
  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final _repo = DonorRepository();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getEligibility();
    setState(() { _loading = false; if (r.isSuccess) _data = r.data; });
  }

  @override
  Widget build(BuildContext context) {
    final isEligible = _data?['isEligible'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Eligibility'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isEligible ? AppColors.success.withOpacity(0.08) : AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(color: isEligible ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Column(children: [
                    Icon(isEligible ? Icons.check_circle : Icons.schedule, size: 64, color: isEligible ? AppColors.success : AppColors.warning),
                    const SizedBox(height: 16),
                    Text(isEligible ? 'Eligible to Donate' : 'Not Currently Eligible',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isEligible ? AppColors.success : AppColors.warning)),
                    const SizedBox(height: 8),
                    Text(_data?['reason'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                  ]),
                ),
                const SizedBox(height: 20),
                _infoRow('Total Donations', '${_data?['totalDonations'] ?? 0}', Icons.volunteer_activism_outlined),
                _infoRow('Next Eligible Date', '${_data?['nextEligibleDate'] ?? 'Now'}', Icons.calendar_today_outlined),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Donation Guidelines', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _guideline('Cooldown period of 90 days between whole blood donations'),
                      _guideline('Donors must be free of fever, infection, or recent surgery'),
                      _guideline('Pregnant or breastfeeding donors are temporarily ineligible'),
                      _guideline('Minimum weight requirement: 50kg'),
                    ]),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _guideline(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.fiber_manual_record, size: 6, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
    ]),
  );
}
