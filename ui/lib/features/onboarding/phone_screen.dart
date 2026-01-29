import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart'; // Import the new widget
import '../../routes/app_routes.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudyBackground( // Use it here!
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 40),
            const Text("Verify your\nPhone Number", style: AppTextStyles.heading),
            const SizedBox(height: 40),
            const Text("Enter the phone number", style: AppTextStyles.label),
            const SizedBox(height: 10),
            const CustomTextField(
              hintText: "1234567890",
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            PrimaryButton(
              text: "Get OTP",
              onTap: () => Navigator.pushNamed(context, AppRoutes.otp),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}