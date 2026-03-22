import 'package:flutter/material.dart';
import '../models/theme_config.dart';

class KeycapWidget extends StatelessWidget {
  final String keyName;
  final ThemeConfig config;

  const KeycapWidget({
    super.key,
    required this.keyName,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = config.specificKeyColors[keyName] ?? config.backgroundColor;
    bool isDarkBg = bgColor.computeLuminance() < 0.5;
    Color txtColor = config.specificKeyColors.containsKey(keyName) 
        ? (isDarkBg ? Colors.white : Colors.black) 
        : config.textColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: config.theme == KeycapTheme.appleMagic
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 0,
                  offset: const Offset(0, -1),
                  spreadRadius: 1,
                )
              ],
        border: config.theme == KeycapTheme.lowProfile 
            ? Border.all(color: Colors.white.withOpacity(0.05), width: 1)
            : null,
      ),
      child: Text(
        keyName,
        style: TextStyle(
          color: txtColor,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
