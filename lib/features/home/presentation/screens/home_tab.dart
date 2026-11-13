import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// The Home Tab screen with platform-adaptive UI (Material for Android, Cupertino for iOS).
/// Adheres to design.md Section 6, 10.1 & user requirements (Floating Action Button "Create story").
class HomeTab extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onScanBill;
  final VoidCallback? onSettleUp;
  final VoidCallback? onBalanceTap;
  final double? youGetAmount;
  final double? youOweAmount;
  final List<RecentExpense>? customExpenses;

  const HomeTab({
    super.key,
    this.onAddExpense,
    this.onScanBill,
    this.onSettleUp,
    this.onBalanceTap,
    this.youGetAmount,
    this.youOweAmount,
    this.customExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Lightning badge, bell icon, Good Evening greeting
              HomeHeader(
                userName: 'Roshan',
                onNotificationPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Expenses Card
              RecentExpensesCard(
                customExpenses: customExpenses,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
