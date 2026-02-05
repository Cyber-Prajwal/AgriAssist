import 'dart:ui';
import 'package:flutter/material.dart';

class CloudyBackground extends StatelessWidget {
  final Widget child;

  const CloudyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Solid Base Layer
          Container(color: const Color(0xFFF7FCF9)),

          // 2. The "Clouds" - Structure matched to image_dca121.png
          Stack(
            children: [
              // TOP-LEFT/CENTER CLOUD (Vertical Oval)
              Positioned(
                top: -80,
                left: 20,
                child: _buildCloud(400, 500, const Color(0xFFD9F2E6)),
              ),

              // TOP-RIGHT CLOUD (Horizontal Oval)
              Positioned(
                top: 20,
                right: -100,
                child: _buildCloud(500, 450, const Color(0xFFD1EFE1)),
              ),

              // MID-BOTTOM LEFT CLOUD
              Positioned(
                bottom: 180,
                left: -80,
                child: _buildCloud(450, 450, const Color(0xFFE3F6ED)),
              ),

              // BOTTOM-RIGHT CLOUD (Large anchor)
              Positioned(
                bottom: -120,
                right: -60,
                child: _buildCloud(550, 500, const Color(0xFFD1EFE1)),
              ),
            ],
          ),

          // 3. High-Intensity Blur Overlay
          // Sigma 90+ gives that smooth "Mesh" look from your screenshots
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 4. Content Layer
          SafeArea(child: child),
        ],
      ),
    );
  }

  // Modified to allow width/height control for oval shapes
  Widget _buildCloud(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}