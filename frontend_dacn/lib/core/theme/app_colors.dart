import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds - Bright, clean, airy palette (from reference image)
  static const Color background = Color(0xFFF6F8F7);
  static const Color scaffoldBackground = Color(0xFFF6F8F7);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSurfaceAccent = Color(0xFFE8F7EE); // Soft sage/mint (from Health card)
  static const Color cardSurfaceBlue = Color(0xFFE4F3FB); // Soft sky blue (from Diagnostics card)
  static const Color cardSurfaceYellow = Color(0xFFFEF3C7); // Soft pastel yellow/amber (from Connect banner)
  static const Color cardSurfacePeach = Color(0xFFFFF0EB); // Soft peach/coral (from Cardiologist card)
  static const Color pillActive = Color(0xFFE0F5E9); // Soft green pill background
  static const Color avatarBg = Color(0xFFEBF5F0); // Soft grey-mint container background

  // Accents - Fresh vibrant Emerald & Mint (high contrast and legibility)
  static const Color primaryMint = Color(0xFF22C55E); // Fresh energetic green - readable and vibrant
  static const Color primaryMintDark = Color(0xFF16A34A); // Slightly deeper green for text on light backgrounds
  static const Color primaryDarkText = Color(0xFFFFFFFF); // Pure white text inside primaryMint buttons
  static const Color border = Color(0xFFE5ECE8); // Subtle, clean border

  // Typography - High-contrast Charcoal & Slate
  static const Color textPrimary = Color(0xFF161F23); // Deep charcoal/near-black
  static const Color textSecondary = Color(0xFF5B6E76); // Medium slate grey for subtitles & units
  static const Color textMuted = Color(0xFF8A9BA2); // Soft muted grey for timestamps and hints

  // Metric specific colors - Fresh and vibrant
  static const Color sleepDark = Color(0xFF433E78); // Deep indigo for sleep chart
  static const Color sleepLight = Color(0xFF8B82F6); // Periwinkle/violet
  static const Color stressActive = Color(0xFFF97316); // Vibrant orange
  static const Color heartRed = Color(0xFFF43F5E); // Vibrant rose/coral red
  static const Color spo2Blue = Color(0xFF0284C7); // Vibrant ocean cyan
}
