import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      setState(() => _isLoading = true);

      // Update Name on backend
      await ApiService.updateUserProfile({"full_name": name});

      setState(() => _isLoading = false);
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.voiceChat, (route) => false);
    }
  }

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
                  CustomTextField(
                      hintText: "Prajwal",
                      controller: _nameController
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
              text: "Submit",
              onTap: _submitName,
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.voiceChat, (route) => false),
              child: const Center(
                  child: Text("Skip for Now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}