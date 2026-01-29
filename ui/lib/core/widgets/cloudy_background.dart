import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CloudyBackground extends StatelessWidget {
  final Widget child;

  const CloudyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Mint Background
          Container(color: const Color(0xFFF0F9F4)),

          // 2. The "Clouds" (Colorful Blobs)
          // Top Left Cloud (Mint)
          Positioned(
            top: -50,
            left: -50,
            child: _buildCloud(250, const Color(0xFFB9E5D1)),
          ),
          // Top Right Cloud (Cream/Yellow)
          Positioned(
            top: 100,
            right: -80,
            child: _buildCloud(300, const Color(0xFFFFF4D9)),
          ),
          // Center Left Cloud (White Glow)
          Positioned(
            top: 300,
            left: -100,
            child: _buildCloud(350, Colors.white.withOpacity(0.8)),
          ),
          // Bottom Right Cloud (Greenish)
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildCloud(300, const Color(0xFFC7EBD7)),
          ),

          // 3. The Blur Overlay (This creates the "Cloudy" effect)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),

          // 4. The actual Page Content
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _buildCloud(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}