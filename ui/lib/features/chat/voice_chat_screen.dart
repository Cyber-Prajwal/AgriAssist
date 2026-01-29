import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cloudy_background.dart';
import '../../routes/app_routes.dart';

class VoiceChatScreen extends StatelessWidget {
  const VoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Top Navigation Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AgriAssist",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Skrubby', // Match the playful font in screenshot
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.notifications_none, size: 32, color: AppColors.primary),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 32, color: AppColors.primary),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.textChat),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Info Chips
            _buildInfoChip(Icons.trending_up, "Today's weather"),
            const SizedBox(height: 12),
            _buildInfoChip(Icons.trending_up, "Latest fertilizers"),

            const Spacer(),

            // Central Character Image
            Container(
              height: 250,
              width: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB2D8C3), // Soft circle background
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/farmer_character.png', // Ensure image is in assets
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const Spacer(),

            const Text(
              "Click on mic to start talking...",
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
            const SizedBox(height: 25),

            // The Dark Green Mic Button
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.botListening),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple effect
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  // Main Dark Green Button
                  Container(
                    height: 85,
                    width: 85,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}