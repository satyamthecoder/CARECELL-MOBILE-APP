import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../shared/presentation/widgets/feature_grid_item.dart';
import '../../../../shared/presentation/widgets/app_bottom_nav.dart';
import '../../../data/repositories/donor_repository.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});
  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _repo = DonorRepository();
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _summary;
  String _userName = '';
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final name = await _storage.read(key: 'user_name');
    final r = await _repo.getDashboard();
    setState(() {
      _loading = false;
      _userName = name ?? 'Donor';
      if (r.isSuccess) _summary = r.data;
    });
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final isEligible = _summary?['isEligible'] == true;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.primary,
              expandedHeight: 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFB71C1C), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Welcome, Hero 🩸', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Eligibility banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEligible ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      border: Border.all(color: isEligible ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Icon(isEligible ? Icons.check_circle : Icons.schedule, color: isEligible ? AppColors.success : AppColors.warning, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(isEligible ? "You're eligible to donate!" : 'Not currently eligible',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isEligible ? AppColors.success : AppColors.warning)),
                          if (!isEligible && _summary?['nextEligibleDate'] != null)
                            Text('Next eligible: ${_summary!['nextEligibleDate']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                      ),
                      TextButton(onPressed: () => context.push('/donor/eligibility'), child: const Text('Details')),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  if (!_loading && _summary != null)
                    Row(children: [
                      Expanded(child: _statCard('Total Donations', '${_summary!['totalDonations'] ?? 0}', Icons.volunteer_activism_outlined, AppColors.bloodRed)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Pending Requests', '${_summary!['pendingRequests'] ?? 0}', Icons.notifications_active_outlined, AppColors.warning)),
                    ]),
                  const SizedBox(height: 24),

                  Text('Donor Services', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      FeatureGridItem(icon: Icons.badge_outlined, label: 'Donor Card', onTap: () => context.push('/donor/profile')),
                      FeatureGridItem(icon: Icons.notifications_active_outlined, label: 'Match Requests', onTap: () => context.push('/donor/matches'), color: AppColors.bloodRed),
                      FeatureGridItem(icon: Icons.history_outlined, label: 'Donation Status', onTap: () => context.push('/donor/eligibility')),
                      FeatureGridItem(icon: Icons.folder_shared_outlined, label: 'Medical Records', onTap: () => context.push('/donor/records')),
                      FeatureGridItem(icon: Icons.local_hospital_outlined, label: 'Hospital Finder', onTap: () => context.push('/donor/hospitals')),
                      FeatureGridItem(icon: Icons.smart_toy_outlined, label: 'CareCell AI', onTap: () => context.push('/donor/ai'), color: AppColors.accent),
                      FeatureGridItem(icon: Icons.person_outline, label: 'My Profile', onTap: () => context.push('/donor/profile')),
                      FeatureGridItem(icon: Icons.verified_user_outlined, label: 'Eligibility', onTap: () => context.push('/donor/eligibility')),
                      FeatureGridItem(icon: Icons.chat_outlined, label: 'WhatsApp', onTap: () {}, color: const Color(0xFF25D366)),
                    ],
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'DONOR'),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}
