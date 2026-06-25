import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});
  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  final _repo = PatientRepository();
  List<dynamic> _hospitals = [];
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

      double lat = 19.0760, lng = 72.8777; // Default: Mumbai
      if (serviceEnabled && permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude; lng = pos.longitude;
      }
      final r = await _repo.getHospitals(lat, lng);
      setState(() { _loading = false; if (r.isSuccess) _hospitals = r.data ?? []; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Finder'), leading: BackButton(onPressed: () => context.pop())),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['All', 'Government', 'Private', 'Specialty'].map((f) {
              final selected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(f), selected: selected, onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary)),
              );
            }).toList()),
          ),
        ),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _hospitals.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.local_hospital_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    const Text('No hospitals found nearby', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: _hospitals.length,
                    itemBuilder: (c, i) {
                      final h = _hospitals[i];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.local_hospital, color: AppColors.info)),
                          title: Text(h['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(h['vicinity'] ?? h['formatted_address'] ?? ''),
                          trailing: h['rating'] != null
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text('${h['rating']}'),
                              ])
                            : null,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ]),
    );
  }
}
