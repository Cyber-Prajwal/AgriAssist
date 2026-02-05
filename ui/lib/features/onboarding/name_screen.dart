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
  String? _errorMessage; // Added to track validation error

  Future<void> _submitName() async {
    final name = _nameController.text.trim();

    // 1. Mandatory Check
    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Name is required to continue";
      });
      return; // Stop execution
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear error if valid
    });

    try {
      // 2. Update Name on backend
      await ApiService.updateUserProfile({"full_name": name});

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.voiceChat, (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  // RichText to show the mandatory asterisk
                  RichText(
                    text: const TextSpan(
                      text: "Enter your name",
                      style: AppTextStyles.label,
                      children: [
                        TextSpan(text: " *", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Enter your name",
                    controller: _nameController,
                    // If your CustomTextField supports an errorBorder or decoration,
                    // you could pass _errorMessage here.
                  ),
                  // 3. Display Error Message below field
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E3D3D)))
                : PrimaryButton(
              text: "Submit",
              onTap: _submitName,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}