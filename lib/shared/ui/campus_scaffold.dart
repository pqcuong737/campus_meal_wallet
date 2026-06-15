import 'package:flutter/material.dart';

import 'campus_colors.dart';

class CampusScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showPattern;

  const CampusScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CampusColors.background,
      appBar: appBar,
      body: Stack(
        children: [
          if (showPattern)
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/images/campus_pattern.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          body,
        ],
      ),
    );
  }
}