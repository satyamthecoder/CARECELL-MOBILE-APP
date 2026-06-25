/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Auth screens
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';

// Patient screens
import '../features/patient/presentation/screens/dashboard/patient_dashboard.dart';
import '../features/patient/presentation/screens/profile/health_profile_screen.dart';
import '../features/patient/presentation/screens/records/health_records_screen.dart';
import '../features/patient/presentation/screens/treatment/treatments_screen.dart';
import '../features/patient/presentation/screens/blood/blood_request_screen.dart';
import '../features/patient/presentation/screens/sos/sos_screen.dart';
import '../features/patient/presentation/screens/hospitals/hospital_finder_screen.dart';
import '../features/patient/presentation/screens/schemes/scheme_finder_screen.dart';
import '../features/patient/presentation/screens/ai/ai_chat_screen.dart';

// Donor screens
import '../features/donor/presentation/screens/dashboard/donor_dashboard.dart';
import '../features/donor/presentation/screens/profile/donor_profile_screen.dart';
import '../features/donor/presentation/screens/matches/match_requests_screen.dart';
import '../features/donor/presentation/screens/records/donor_records_screen.dart';
import '../features/donor/presentation/screens/eligibility/eligibility_screen.dart';

// Shared
import '../features/shared/presentation/screens/health_card_screen.dart';

class AppRouter {
  static final _storage = FlutterSecureStorage();

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final token = await _storage.read(key: 'access_token');
      final role  = await _storage.read(key: 'user_role');
      final isAuth = token != null;
      final onAuth = state.matchedLocation.startsWith('/splash') ||
                     state.matchedLocation.startsWith('/welcome') ||
                     state.matchedLocation.startsWith('/login') ||
                     state.matchedLocation.startsWith('/register') ||
                     state.matchedLocation.startsWith('/otp') ||
                     state.matchedLocation.startsWith('/forgot');

      if (!isAuth && !onAuth) return '/welcome';
      if (isAuth && onAuth && !state.matchedLocation.startsWith('/splash')) {
        return role == 'DONOR' ? '/donor/dashboard' : '/patient/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash',   builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome',  builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/login',    builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/otp',      builder: (c, s) => OtpScreen(
        mobile: s.uri.queryParameters['mobile'] ?? '',
        nextRoute: s.uri.queryParameters['next'] ?? '/patient/dashboard',
      )),
      GoRoute(path: '/forgot',   builder: (c, s) => const ForgotPasswordScreen()),

      // ── Patient routes ────────────────────────
      GoRoute(path: '/patient/dashboard',  builder: (c, s) => const PatientDashboard()),
      GoRoute(path: '/patient/profile',    builder: (c, s) => const HealthProfileScreen()),
      GoRoute(path: '/patient/records',    builder: (c, s) => const HealthRecordsScreen()),
      GoRoute(path: '/patient/treatments', builder: (c, s) => const TreatmentsScreen()),
      GoRoute(path: '/patient/blood',      builder: (c, s) => const BloodRequestScreen()),
      GoRoute(path: '/patient/sos',        builder: (c, s) => const SosScreen()),
      GoRoute(path: '/patient/hospitals',  builder: (c, s) => const HospitalFinderScreen()),
      GoRoute(path: '/patient/schemes',    builder: (c, s) => const SchemeFinderScreen()),
      GoRoute(path: '/patient/ai',         builder: (c, s) => const AiChatScreen()),
      GoRoute(path: '/health-card',        builder: (c, s) => const HealthCardScreen()),

      // ── Donor routes ──────────────────────────
      GoRoute(path: '/donor/dashboard',   builder: (c, s) => const DonorDashboard()),
      GoRoute(path: '/donor/profile',     builder: (c, s) => const DonorProfileScreen()),
      GoRoute(path: '/donor/matches',     builder: (c, s) => const MatchRequestsScreen()),
      GoRoute(path: '/donor/records',     builder: (c, s) => const DonorRecordsScreen()),
      GoRoute(path: '/donor/eligibility', builder: (c, s) => const EligibilityScreen()),
      GoRoute(path: '/donor/hospitals',   builder: (c, s) => const HospitalFinderScreen()),
      GoRoute(path: '/donor/ai',          builder: (c, s) => const AiChatScreen()),
    ],
    errorBuilder: (c, s) => Scaffold(
      body: Center(child: Text('Page not found: ${s.uri}')),
    ),
  );
}
*/



// new path replaced 

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

// Patient screens
import '../../features/patient/presentation/screens/dashboard/patient_dashboard.dart';
import '../../features/patient/presentation/screens/profile/health_profile_screen.dart';
import '../../features/patient/presentation/screens/records/health_records_screen.dart';
import '../../features/patient/presentation/screens/treatment/treatments_screen.dart';
import '../../features/patient/presentation/screens/blood/blood_request_screen.dart';
import '../../features/patient/presentation/screens/sos/sos_screen.dart';
import '../../features/patient/presentation/screens/hospitals/hospital_finder_screen.dart';
import '../../features/patient/presentation/screens/schemes/scheme_finder_screen.dart';
import '../../features/patient/presentation/screens/ai/ai_chat_screen.dart';

// Donor screens
import '../../features/donor/presentation/screens/dashboard/donor_dashboard.dart';
import '../../features/donor/presentation/screens/profile/donor_profile_screen.dart';
import '../../features/donor/presentation/screens/matches/match_requests_screen.dart';
import '../../features/donor/presentation/screens/records/donor_records_screen.dart';
import '../../features/donor/presentation/screens/eligibility/eligibility_screen.dart';

// Shared
import '../../features/shared/presentation/screens/health_card_screen.dart';

class AppRouter {
  static final _storage = FlutterSecureStorage();

  static final router = GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) async {
      final token = await _storage.read(key: 'access_token');
      final role = await _storage.read(key: 'user_role');

      final isAuth = token != null;

      final onAuth =
          state.matchedLocation.startsWith('/splash') ||
          state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/forgot');

      if (!isAuth && !onAuth) {
        return '/welcome';
      }

      if (isAuth &&
          onAuth &&
          !state.matchedLocation.startsWith('/splash')) {
        return role == 'DONOR'
            ? '/donor/dashboard'
            : '/patient/dashboard';
      }

      return null;
    },

    routes: [

      // Auth routes
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),

      GoRoute(
        path: '/welcome',
        builder: (c, s) => const WelcomeScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (c, s) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (c, s) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/otp',
        builder: (c, s) => OtpScreen(
          mobile: s.uri.queryParameters['mobile'] ?? '',
          nextRoute:
              s.uri.queryParameters['next']
                  ?? '/patient/dashboard',
        ),
      ),

      GoRoute(
        path: '/forgot',
        builder: (c, s) => const ForgotPasswordScreen(),
      ),

      // Patient routes

      GoRoute(
        path: '/patient/dashboard',
        builder: (c, s) => const PatientDashboard(),
      ),

      GoRoute(
        path: '/patient/profile',
        builder: (c, s) => const HealthProfileScreen(),
      ),

      GoRoute(
        path: '/patient/records',
        builder: (c, s) => const HealthRecordsScreen(),
      ),

      GoRoute(
        path: '/patient/treatments',
        builder: (c, s) => const TreatmentsScreen(),
      ),

      GoRoute(
        path: '/patient/blood',
        builder: (c, s) => const BloodRequestScreen(),
      ),

      GoRoute(
        path: '/patient/sos',
        builder: (c, s) => const SosScreen(),
      ),

      GoRoute(
        path: '/patient/hospitals',
        builder: (c, s) => const HospitalFinderScreen(),
      ),

      GoRoute(
        path: '/patient/schemes',
        builder: (c, s) => const SchemeFinderScreen(),
      ),

      GoRoute(
        path: '/patient/ai',
        builder: (c, s) => const AiChatScreen(),
      ),

      GoRoute(
        path: '/health-card',
        builder: (c, s) => const HealthCardScreen(),
      ),

      // Donor routes

      GoRoute(
        path: '/donor/dashboard',
        builder: (c, s) => const DonorDashboard(),
      ),

      GoRoute(
        path: '/donor/profile',
        builder: (c, s) => const DonorProfileScreen(),
      ),

      GoRoute(
        path: '/donor/matches',
        builder: (c, s) => const MatchRequestsScreen(),
      ),

      GoRoute(
        path: '/donor/records',
        builder: (c, s) => const DonorRecordsScreen(),
      ),

      GoRoute(
        path: '/donor/eligibility',
        builder: (c, s) => const EligibilityScreen(),
      ),

      GoRoute(
        path: '/donor/hospitals',
        builder: (c, s) => const HospitalFinderScreen(),
      ),

      GoRoute(
        path: '/donor/ai',
        builder: (c, s) => const AiChatScreen(),
      ),
    ],

    errorBuilder: (c, s) => Scaffold(
      body: Center(
        child: Text('Page not found: ${s.uri}'),
      ),
    ),
  );
}