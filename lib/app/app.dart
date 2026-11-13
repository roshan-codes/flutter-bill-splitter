import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_theme.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/splash_screen.dart';

/// Root Application Widget.
class MyApp extends StatelessWidget {
  final Widget? home;

  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTMM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home ?? const SplashScreen(),
    );
  }
}
