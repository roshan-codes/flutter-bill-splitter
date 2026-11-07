import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/balance_card.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';

/// The Home Tab screen matching the user-provided neumorphic design.
class HomeTab extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback? onScanBill;
  final VoidCallback? onSettleUp;
  final VoidCallback? onBalanceTap;

  const HomeTab({
    super.key,
    required this.onAddExpense,
    this.onScanBill,
    this.onSettleUp,
    this.onBalanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Lightning badge, bell icon, Good Evening Roshan 👋
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
              const SizedBox(height: 22),

              // 3 Quick Action Tiles: Add Expense, Scan Bill, Settle Up
              HomeQuickActions(
                onAddExpense: onAddExpense,
                onScanBill: () {
                  if (onScanBill != null) {
                    onScanBill!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bill Scanner feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onSettleUp: () {
                  if (onSettleUp != null) {
                    onSettleUp!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settle Up feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 22),

              // Balance Card: You get vs You owe
              BalanceCard(
                onTap: onBalanceTap,
              ),
              const SizedBox(height: 22),

              // Recent Expenses Card: Dinner at Sakali, Goa Trip Fuel, Groceries
              const RecentExpensesCard(),
            ],
          ),
        ),
      ),
    );
  }
}
