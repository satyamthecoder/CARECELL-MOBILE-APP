import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final String role; // PATIENT or DONOR
  const AppBottomNav({super.key, required this.currentIndex, required this.role});

  @override
  Widget build(BuildContext context) {
    final isPatient = role == 'PATIENT';
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        final prefix = isPatient ? '/patient' : '/donor';
        switch (i) {
          case 0: context.go('$prefix/dashboard'); break;
          case 1: context.go(isPatient ? '/patient/records' : '/donor/records'); break;
          case 2: context.go(isPatient ? '/patient/ai' : '/donor/ai'); break;
          case 3: context.go(isPatient ? '/patient/hospitals' : '/donor/eligibility'); break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Records'),
        const BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'AI Chat'),
        BottomNavigationBarItem(
          icon: Icon(isPatient ? Icons.local_hospital_outlined : Icons.verified_user_outlined),
          activeIcon: Icon(isPatient ? Icons.local_hospital : Icons.verified_user),
          label: isPatient ? 'Hospitals' : 'Eligibility',
        ),
      ],
    );
  }
}
