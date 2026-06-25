import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.local_hospital, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text('CareCell', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('AI-Powered Healthcare\nAssistance Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                const Spacer(),
                const Text('Join as', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 20),
                _RoleCard(
                  icon: Icons.person_outline,
                  title: 'Patient',
                  subtitle: 'Access health services, records, emergency help & government schemes',
                  onTap: () => context.push('/register?role=PATIENT'),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.bloodtype_outlined,
                  title: 'Blood Donor',
                  subtitle: 'Register as a donor, track donations & respond to blood requests',
                  isSecondary: true,
                  onTap: () => context.push('/register?role=DONOR'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSecondary;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.isSecondary = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSecondary ? Colors.white.withOpacity(0.15) : Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: isSecondary ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSecondary ? Colors.white : AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSecondary ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: isSecondary ? Colors.white70 : AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: isSecondary ? Colors.white70 : AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
