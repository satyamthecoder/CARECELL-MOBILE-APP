import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  CareCell — App Constants
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const primary        = Color(0xFF1B5E20);   // Deep forest green
  static const primaryLight   = Color(0xFF4CAF50);   // Medium green
  static const primaryDark    = Color(0xFF0A3D0A);   // Dark green
  static const accent         = Color(0xFF00BCD4);   // Teal/cyan accent
  static const accentLight    = Color(0xFF80DEEA);

  // Semantic
  static const emergency      = Color(0xFFD32F2F);   // SOS red
  static const warning        = Color(0xFFFF9800);
  static const success        = Color(0xFF2E7D32);
  static const info           = Color(0xFF1976D2);

  // Neutrals
  static const background     = Color(0xFFF8FBF8);
  static const surface        = Color(0xFFFFFFFF);
  static const cardBg         = Color(0xFFFFFFFF);
  static const divider        = Color(0xFFE0E0E0);

  // Text
  static const textPrimary    = Color(0xFF1A1A1A);
  static const textSecondary  = Color(0xFF757575);
  static const textHint       = Color(0xFFBDBDBD);
  static const textOnPrimary  = Color(0xFFFFFFFF);

  // Blood group chip colors
  static const bloodRed       = Color(0xFFC62828);
  static const bloodRedLight  = Color(0xFFFFEBEE);
}

class AppStrings {
  AppStrings._();
  static const appName        = 'CareCell';
  static const tagline        = 'Your Health, Our Priority';
  static const version        = '1.0.0';
}

class AppEndpoints {
  AppEndpoints._();
  // TODO: Replace with your actual server URL before deploying
 // static const baseUrl        = 'https://api.carecell.in';
  static const baseUrl = 'http://10.0.2.2:8080';
  static const apiVersion     = '/api/v1';

  // Auth
  static const register       = '$apiVersion/auth/register';
  static const sendOtp        = '$apiVersion/auth/send-otp';
  static const verifyOtp      = '$apiVersion/auth/verify-otp';
  static const login          = '$apiVersion/auth/login';
  static const refresh        = '$apiVersion/auth/refresh-token';
  static const forgotPassword = '$apiVersion/auth/forgot-password';
  static const resetPassword  = '$apiVersion/auth/reset-password';

  // Patient
  static const patientDash    = '$apiVersion/patient/dashboard';
  static const healthProfile  = '$apiVersion/patient/profile/health';
  static const healthCard     = '$apiVersion/patient/health-card';
  static const emergencyCtx   = '$apiVersion/patient/emergency-contacts';
  static const sos            = '$apiVersion/patient/sos';
  static const bloodRequests  = '$apiVersion/patient/blood-requests';
  static const patientRecords = '$apiVersion/patient/records';
  static const treatments     = '$apiVersion/patient/treatments';

  // Donor
  static const donorDash      = '$apiVersion/donor/dashboard';
  static const donorProfile   = '$apiVersion/donor/profile';
  static const donorCard      = '$apiVersion/donor/donor-card';
  static const matchRequests  = '$apiVersion/donor/match-requests';
  static const donorRecords   = '$apiVersion/donor/records';
  static const eligibility    = '$apiVersion/donor/eligibility';
  static const location       = '$apiVersion/donor/location';

  // Public
  static const hospitals      = '$apiVersion/public/hospitals';
  static const schemes        = '$apiVersion/public/schemes';
  static const aiChat         = '$apiVersion/public/ai/chat';
  static const healthTips     = '$apiVersion/public/health-tips';
}

class AppDimensions {
  AppDimensions._();
  static const paddingXS   = 4.0;
  static const paddingS    = 8.0;
  static const paddingM    = 16.0;
  static const paddingL    = 24.0;
  static const paddingXL   = 32.0;
  static const radiusS     = 8.0;
  static const radiusM     = 12.0;
  static const radiusL     = 16.0;
  static const radiusXL    = 24.0;
  static const radiusFull  = 100.0;
  static const iconS       = 18.0;
  static const iconM       = 24.0;
  static const iconL       = 32.0;
}
