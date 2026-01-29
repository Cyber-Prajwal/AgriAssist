import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row Element (Eng Dropdown)
            // Functionally occupies the same "header" space as the Back Button in OtpScreen
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("Eng"), Icon(Icons.keyboard_arrow_down, size: 16)],
                ),
              ),
            ),

            // Fixed spacing to match OtpScreen's gap between top element and heading
            const SizedBox(height: 40),

            const Text("Verify your\nPhone Number", style: AppTextStyles.heading),
            const SizedBox(height: 40),
            const Text("Enter the phone number", style: AppTextStyles.label),
            const SizedBox(height: 10),
            const CustomTextField(
              hintText: "1234567890",
              keyboardType: TextInputType.phone,
            ),

            // This pushes the button to the bottom, exactly like in OtpScreen
            const Spacer(),

            PrimaryButton(
              text: "Get OTP",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.otp);
              },
            ),

            // Fixed bottom spacing to match OtpScreen
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}