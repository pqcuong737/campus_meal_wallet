import 'package:campus_meal_wallet/shared/ui/campus_theme.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // title: 'Campus Meal Wallet',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: CampusTheme.light(),
  );}}