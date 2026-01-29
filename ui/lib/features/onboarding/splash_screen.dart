import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Phone Screen after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.phone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the Logo in the screenshot
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.blue[300], // Adjust based on asset
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    // Use your asset path here: 'assets/logo.png'
                    image: NetworkImage("https://via.placeholder.com/150"),
                    fit: BoxFit.cover,
                  )
              ),
              child: const Icon(Icons.agriculture, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "AgriAssist",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}