import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("Eng"), Icon(Icons.keyboard_arrow_down, size: 16)],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text("What's your\nname?", style: AppTextStyles.heading),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter your name", style: AppTextStyles.label),
                  const SizedBox(height: 10),
                  const CustomTextField(hintText: "Prajwal"),
                ],
              ),
            ),
            PrimaryButton(
              text: "Submit",
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.voiceChat, (route) => false),
            ),
            const SizedBox(height: 15),
            const Center(child: Text("Skip for Now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}