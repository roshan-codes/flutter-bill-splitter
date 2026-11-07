import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_theme.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';

/// Root Application Widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
