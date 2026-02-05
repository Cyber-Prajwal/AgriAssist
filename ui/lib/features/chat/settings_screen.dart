import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F8EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _settingsCard(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Change app language',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _settingsCard(
              icon: Icons.record_voice_over,
              title: 'Voice',
              subtitle: 'Voice assistant preferences',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _settingsCard(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Get support and FAQs',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _settingsCard(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version & information',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SETTINGS CARD ----------------
  Widget _settingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON CONTAINER
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0E3D3D).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0E3D3D),
                size: 22,
              ),
            ),

            const SizedBox(width: 16),

            /// TEXT
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
