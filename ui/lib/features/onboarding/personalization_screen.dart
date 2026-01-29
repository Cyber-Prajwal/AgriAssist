import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/option_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  String? ownFarm;
  String? waterSupply;
  String? landType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set resizeToAvoidBottomInset to false to keep background consistent
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            // 1. Back Button (Matches OtpScreen top element)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),

            // 2. Exact same gap as OtpScreen (40)
            const SizedBox(height: 40),

            // 3. Heading
            const Text("Get personalised\nexperience", style: AppTextStyles.heading),

            const SizedBox(height: 30),

            // 4. Content Area (Scrollable if needed, but flexed to push button down)
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
                      children: [
                        OptionChip(label: "Rain", isSelected: waterSupply == "Rain", onTap: () => setState(() => waterSupply = "Rain")),
                        OptionChip(label: "Well", isSelected: waterSupply == "Well", onTap: () => setState(() => waterSupply = "Well")),
                        OptionChip(label: "River", isSelected: waterSupply == "River", onTap: () => setState(() => waterSupply = "River")),
                        OptionChip(label: "Channel", isSelected: waterSupply == "Channel", onTap: () => setState(() => waterSupply = "Channel")),
                      ],
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
                    const SizedBox(height: 20), // Extra padding for scroll breathing room
                  ],
                ),
              ),
            ),

            // 5. Button Pinned to Bottom (Matches OtpScreen)
            const SizedBox(height: 20),
            PrimaryButton(
              text: "Next →",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.name);
              },
            ),

            // 6. Fixed bottom spacing (Matches OtpScreen)
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF344054),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
