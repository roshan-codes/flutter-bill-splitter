import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Presentation domain model representing an item displayed on the Activity tab.
class ActivityDisplayItem {
  final String id;
  final String title;
  final int memberCount;
  final double totalAmount;
  final String statusText;
  final Color statusColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String section; // 'This Week' or 'Last Week'
  final bool isSettlement;
  final SplitActivity? splitActivity;

  const ActivityDisplayItem({
    required this.id,
    required this.title,
    required this.memberCount,
    required this.totalAmount,
    required this.statusText,
    required this.statusColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.section,
    this.isSettlement = false,
    this.splitActivity,
  });
}
