import 'package:flutter/material.dart';

import 'campus_colors.dart';

enum CampusButtonType {
  primary,
  danger,
  normal,
}

class CampusButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CampusButtonType type;
  final IconData? icon;

  const CampusButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = CampusButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final background = switch (type) {
      CampusButtonType.primary => CampusColors.primary,
      CampusButtonType.danger => CampusColors.danger,
      CampusButtonType.normal => Colors.white,
    };

    final foreground = switch (type) {
      CampusButtonType.normal => CampusColors.text,
      _ => Colors.white,
    };

    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(
              color: CampusColors.border,
              width: 2.6,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
          child: child,
        ),
      ),
    );
  }
}