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
  bool _showErrors = false;

  Future<void> _submitData() async {
    if (ownFarm == null || waterSupply == null || landType == null) {
      setState(() {
        _showErrors = true;
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _showErrors = false;
    });

    Map<String, String> data = {
      'has_farm': ownFarm!,
      'water_supply': waterSupply!,
      'farm_type': landType!,
    };

    try {
      await ApiService.updateUserProfile(data);
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Adjusted Helper: Text stays same color, only error message shows
  Widget _buildSectionTitle(String title, bool isSelected) {
    bool showError = _showErrors && !isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF344054), // Fixed color (doesn't turn red)
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          // Only show the red error text below if field is missing
          if (showError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Please select an option",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CloudyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text("Get personalised\nexperience", style: AppTextStyles.heading),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Do you have your own farm?", ownFarm != null),
                    Row(
                      children: [
                        OptionChip(
                          label: "Yes",
                          isSelected: ownFarm == "Yes",
                          onTap: () => setState(() {
                            ownFarm = "Yes";
                            if (ownFarm != null) _showErrors = false; // Optional: hide error on select
                          }),
                        ),
                        const SizedBox(width: 12),
                        OptionChip(
                          label: "No",
                          isSelected: ownFarm == "No",
                          onTap: () => setState(() => ownFarm = "No"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    _buildSectionTitle("Which water supply do you have?", waterSupply != null),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ["Rain", "Well", "River", "Channel"].map((e) =>
                          OptionChip(
                            label: e,
                            isSelected: waterSupply == e,
                            onTap: () => setState(() => waterSupply = e),
                          )
                      ).toList(),
                    ),
                    const SizedBox(height: 30),

                    _buildSectionTitle("Which land type do you have?", landType != null),
                    Row(
                      children: [
                        OptionChip(
                          label: "Koradvahu",
                          isSelected: landType == "Koradvahu",
                          onTap: () => setState(() => landType = "Koradvahu"),
                        ),
                        const SizedBox(width: 12),
                        OptionChip(
                          label: "Bagayati",
                          isSelected: landType == "Bagayati",
                          onTap: () => setState(() => landType = "Bagayati"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E3D3D)))
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
}