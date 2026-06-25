import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/donor_repository.dart';

class MatchRequestsScreen extends StatefulWidget {
  const MatchRequestsScreen({super.key});
  @override
  State<MatchRequestsScreen> createState() => _MatchRequestsScreenState();
}

class _MatchRequestsScreenState extends State<MatchRequestsScreen> {
  final _repo = DonorRepository();
  List<dynamic> _requests = [];
  bool _loading = true;
  final _displayMap = {'A_POSITIVE':'A+','A_NEGATIVE':'A-','B_POSITIVE':'B+','B_NEGATIVE':'B-','AB_POSITIVE':'AB+','AB_NEGATIVE':'AB-','O_POSITIVE':'O+','O_NEGATIVE':'O-'};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await _repo.getMatchRequests();
    setState(() { _loading = false; if (r.isSuccess) _requests = r.data ?? []; });
  }

  Future<void> _respond(String id, String action) async {
    final r = await _repo.respondToRequest(id, action);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r.isSuccess ? 'Response recorded: $action' : (r.error ?? 'Failed')),
      backgroundColor: r.isSuccess ? AppColors.success : AppColors.emergency,
    ));
    _load();
  }

  Color _urgencyColor(String? u) {
    switch (u) {
      case 'CRITICAL': return AppColors.emergency;
      case 'HIGH': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Requests'), leading: BackButton(onPressed: () => context.pop())),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _requests.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('No match requests right now', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Text("We'll notify you when you're matched", style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ]),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                itemCount: _requests.length,
                itemBuilder: (c, i) {
                  final req = _requests[i];
                  final pending = req['status'] == 'PENDING';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(backgroundColor: AppColors.bloodRedLight, child: Text(_displayMap[req['requiredBloodGroup']] ?? '?', style: const TextStyle(color: AppColors.bloodRed, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(req['hospitalName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(req['hospitalCity'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                          ),
                          Chip(label: Text(req['urgencyLevel'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: _urgencyColor(req['urgencyLevel'])),
                        ]),
                        const SizedBox(height: 8),
                        Text('Type: ${(req['donationType'] ?? '').toString().replaceAll('_', ' ')}', style: const TextStyle(fontSize: 13)),
                        if (req['additionalNotes'] != null && req['additionalNotes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(req['additionalNotes'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                        if (pending) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: OutlinedButton(onPressed: () => _respond(req['id'], 'DECLINE'), child: const Text('Decline'))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton(onPressed: () => _respond(req['id'], 'ACCEPT'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('Accept'))),
                          ]),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Chip(label: Text(req['status'] ?? ''), backgroundColor: AppColors.background),
                          ),
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
