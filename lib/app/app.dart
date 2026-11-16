import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/routing/app_auth_gate.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_theme.dart';

/// Root Application Widget.
class MyApp extends StatelessWidget {
  final Widget? home;

  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: InviteService.navigatorKey,
      title: 'TTMM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home ?? const AppAuthGate(),
    );
  }
}
