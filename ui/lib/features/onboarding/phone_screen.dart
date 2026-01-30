import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _validateAndSubmit() async {
    final value = _phoneController.text.trim();

    // Client-side validation
    if (value.isEmpty) {
      setState(() => _errorMessage = "It must not be blank");
      return;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      setState(() => _errorMessage = "Only numeric values are allowed");
      return;
    } else if (!RegExp(r'^[6-9]').hasMatch(value)) {
      setState(() => _errorMessage = "Please enter a valid number");
      return;
    } else if (value.length != 10) {
      setState(() => _errorMessage = "Must be a 10 digit number");
      return;
    }

    // Call API
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    bool success = await ApiService.sendOtp(value);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushNamed(context, AppRoutes.otp);
    } else if (mounted) {
      setState(() => _errorMessage = "Failed to send OTP. Try again.");
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
            const SizedBox(height: 80),
            const Text("Verify your\nPhone Number", style: AppTextStyles.heading),
            const SizedBox(height: 40),
            const Text("Enter the phone number", style: AppTextStyles.label),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "1234567890",
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              errorText: _errorMessage,
            ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(text: "Get OTP", onTap: _validateAndSubmit),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}