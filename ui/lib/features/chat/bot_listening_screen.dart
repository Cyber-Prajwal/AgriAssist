import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cloudy_background.dart';

class BotListeningScreen extends StatelessWidget {
  const BotListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Header - Changed color to AppColors.primary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AgriAssist",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Matches dark text in photo
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.notifications_none, size: 32, color: AppColors.primary),
                    SizedBox(width: 15),
                    Icon(Icons.settings_outlined, size: 32, color: AppColors.primary),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Character Image with Grey/Teal border
            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB9E5D1).withOpacity(0.8), // Softer border like photo
                  width: 12,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/listening.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Subtitle Text - Changed to AppColors.primary
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "I am listening to you, please speak clearly...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary, // Dark teal text
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleAction(Icons.chat_bubble_outline),
                _buildRippleMic(),
                _buildCircleAction(Icons.close),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRippleMic() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ripple matching the soft teal background
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        // Main Mic Button
        Container(
          height: 85,
          width: 85,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary, // Dark teal center
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 35),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1), // Soft teal/grey background
      ),
      child: Icon(icon, color: AppColors.primary, size: 28), // Dark icons
    );
  }
}