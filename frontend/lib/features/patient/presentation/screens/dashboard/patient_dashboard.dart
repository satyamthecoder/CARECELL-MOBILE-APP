import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../shared/presentation/widgets/feature_grid_item.dart';
import '../../../../shared/presentation/widgets/app_bottom_nav.dart';
import '../../../data/repositories/patient_repository.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});
  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final _repo = PatientRepository();
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
      _userName = name ?? 'Patient';
      if (r.isSuccess) _summary = r.data;
    });
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
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
                    gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
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

                  // SOS Banner — always accessible per PRD
                  GestureDetector(
                    onTap: () => context.push('/patient/sos'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emergency,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        boxShadow: [BoxShadow(color: AppColors.emergency.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(Icons.sos, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Emergency SOS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('One-tap alert to your emergency contacts', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ]),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick stats
                  if (!_loading && _summary != null)
                    Row(children: [
                      Expanded(child: _statCard('Records', '${_summary!['recordCount'] ?? 0}', Icons.folder_outlined, AppColors.info)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Blood Requests', '${_summary!['activeBloodRequests'] ?? 0}', Icons.bloodtype_outlined, AppColors.bloodRed)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Treatments', '${_summary!['ongoingTreatments'] ?? 0}', Icons.medical_services_outlined, AppColors.success)),
                    ]),
                  const SizedBox(height: 24),

                  Text('Healthcare Services', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      FeatureGridItem(icon: Icons.badge_outlined, label: 'Health Card', onTap: () => context.push('/health-card')),
                      FeatureGridItem(icon: Icons.bloodtype_outlined, label: 'Blood Request', onTap: () => context.push('/patient/blood'), color: AppColors.bloodRed),
                      FeatureGridItem(icon: Icons.folder_shared_outlined, label: 'Health Records', onTap: () => context.push('/patient/records')),
                      FeatureGridItem(icon: Icons.medical_services_outlined, label: 'Treatment Tracker', onTap: () => context.push('/patient/treatments')),
                      FeatureGridItem(icon: Icons.local_hospital_outlined, label: 'Hospital Finder', onTap: () => context.push('/patient/hospitals')),
                      FeatureGridItem(icon: Icons.policy_outlined, label: 'Scheme Finder', onTap: () => context.push('/patient/schemes')),
                      FeatureGridItem(icon: Icons.smart_toy_outlined, label: 'CareCell AI', onTap: () => context.push('/patient/ai'), color: AppColors.accent),
                      FeatureGridItem(icon: Icons.person_outline, label: 'Health Profile', onTap: () => context.push('/patient/profile')),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'PATIENT'),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}
