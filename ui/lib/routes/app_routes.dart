import 'package:flutter/material.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/phone_screen.dart';
import '../features/onboarding/otp_screen.dart';
import '../features/onboarding/personalization_screen.dart';
import '../features/onboarding/name_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String personalization = '/personalization';
  static const String name = '/name';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    phone: (context) => const PhoneScreen(),
    otp: (context) => const OtpScreen(),
    personalization: (context) => const PersonalizationScreen(),
    name: (context) => const NameScreen(),
  };
}