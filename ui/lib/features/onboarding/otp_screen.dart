import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/otp_box.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),
            const Text("Enter the OTP sent to\nyour number", style: AppTextStyles.heading),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OtpBox(), OtpBox(), OtpBox(), OtpBox(), OtpBox(), OtpBox(),
              ],
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: const TextSpan(
                  text: "Resend",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: " in 04:23",
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: "Next →",
              onTap: () => Navigator.pushNamed(context, AppRoutes.personalization),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}