import 'package:flutter/material.dart';

enum KeycapTheme {
  appleMagic,
  lowProfile,
  custom
}

class ThemeConfig {
  final KeycapTheme theme;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final Map<String, Color> specificKeyColors;

  const ThemeConfig({
    required this.theme,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    this.specificKeyColors = const {},
  });

  factory ThemeConfig.appleMagic() {
    return const ThemeConfig(
      theme: KeycapTheme.appleMagic,
      backgroundColor: Color(0xFFF5F5F7),
      textColor: Color(0xFF1D1D1F),
      borderRadius: 8.0,
    );
  }

  factory ThemeConfig.lowProfile() {
    return const ThemeConfig(
      theme: KeycapTheme.lowProfile,
      backgroundColor: Color(0xFF2C2C2E),
      textColor: Color(0xFFF5F5F7),
      borderRadius: 4.0,
    );
  }
  
  ThemeConfig copyWith({
    KeycapTheme? theme,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    Map<String, Color>? specificKeyColors,
  }) {
    return ThemeConfig(
      theme: theme ?? this.theme,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      specificKeyColors: specificKeyColors ?? this.specificKeyColors,
    );
  }
}
