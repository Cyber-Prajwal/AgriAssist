import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/option_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  String? ownFarm;
  String? waterSupply;
  String? landType;
  bool _isLoading = false;

  Future<void> _submitData() async {
    setState(() => _isLoading = true);

    // Prepare data map for Form update
    // Note: Backend expects keys: has_farm, water_supply, farm_type
    Map<String, String> data = {};
    if (ownFarm != null) data['has_farm'] = ownFarm!;
    if (waterSupply != null) data['water_supply'] = waterSupply!;
    if (landType != null) data['farm_type'] = landType!;

    // We send what we have. Even if empty, we move next.
    if (data.isNotEmpty) {
      await ApiService.updateUserProfile(data);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.name);
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),
            const Text("Get personalised\nexperience", style: AppTextStyles.heading),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Do you have your own farm?"),
                    Row(
                      children: [
                        OptionChip(label: "Yes", isSelected: ownFarm == "Yes", onTap: () => setState(() => ownFarm = "Yes")),
                        const SizedBox(width: 12),
                        OptionChip(label: "No", isSelected: ownFarm == "No", onTap: () => setState(() => ownFarm = "No")),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Which water supply do you have?"),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ["Rain", "Well", "River", "Channel"].map((e) =>
                          OptionChip(label: e, isSelected: waterSupply == e, onTap: () => setState(() => waterSupply = e))
                      ).toList(),
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Which land type do you have?"),
                    Row(
                      children: [
                        OptionChip(label: "Koradvahu", isSelected: landType == "Koradvahu", onTap: () => setState(() => landType = "Koradvahu")),
                        const SizedBox(width: 12),
                        OptionChip(label: "Bagayati", isSelected: landType == "Bagayati", onTap: () => setState(() => landType = "Bagayati")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
              text: "Next →",
              onTap: _submitData,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF344054), fontWeight: FontWeight.w500)),
    );
  }
}