import 'package:flutter/material.dart';

import 'campus_colors.dart';

class CampusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  const CampusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = CampusColors.surface,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CampusColors.border,
          width: 2.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: CampusColors.border,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: content,
    );
  }
}