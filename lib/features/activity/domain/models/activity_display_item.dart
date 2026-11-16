import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
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
  final String section; // 'Today', 'Yesterday', 'This Week', 'Last Week'
  final bool isSettlement;
  final SplitActivity? splitActivity;
  final String? subtitleAmount;
  final String? timestamp;
  final String? trailingText;
  final Color? trailingColor;
  final String type; // 'expense', 'settlement', 'member'
  final String? subtitle;

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
    this.subtitleAmount,
    this.timestamp,
    this.trailingText,
    this.trailingColor,
    this.type = 'expense',
    this.subtitle,
  });

  /// Sample feed matching the design mockup (media_1794729268088_39ebec66.jpg)
  static const List<ActivityDisplayItem> mockupFeed = [
    // Today
    ActivityDisplayItem(
      id: 'act_mock_1',
      title: 'Shubham settled',
      subtitleAmount: '₹3,000 with you',
      timestamp: 'Delhi · 12:45 PM',
      trailingText: '+₹3,000',
      trailingColor: Color(0xFF16A34A),
      memberCount: 2,
      totalAmount: 3000.0,
      statusText: 'Settled',
      statusColor: Color(0xFF16A34A),
      icon: Icons.check_rounded,
      iconBgColor: Color(0xFFE8F8EE),
      iconColor: Color(0xFF16A34A),
      section: 'Today',
      isSettlement: true,
      type: 'settlement',
    ),
    ActivityDisplayItem(
      id: 'act_mock_2',
      title: 'You added Dinner',
      subtitleAmount: '₹2,400',
      timestamp: 'Delhi · 11:20 AM',
      trailingText: '-₹2,400',
      trailingColor: Color(0xFFE53935),
      memberCount: 3,
      totalAmount: 2400.0,
      statusText: 'Dinner',
      statusColor: Color(0xFFE53935),
      icon: Icons.restaurant_outlined,
      iconBgColor: Color(0xFFFEECEB),
      iconColor: Color(0xFFE53935),
      section: 'Today',
      isSettlement: false,
      type: 'expense',
    ),
    ActivityDisplayItem(
      id: 'act_mock_3',
      title: 'Rashmi added Hotel Stay',
      subtitleAmount: '₹6,000',
      timestamp: 'Delhi · 10:30 AM',
      trailingText: '₹6,000',
      trailingColor: Color(0xFF111827),
      memberCount: 3,
      totalAmount: 6000.0,
      statusText: 'Hotel Stay',
      statusColor: Color(0xFF111827),
      icon: Icons.hotel_outlined,
      iconBgColor: Color(0xFFFFF4E6),
      iconColor: Color(0xFF1E1E1E),
      section: 'Today',
      isSettlement: false,
      type: 'expense',
    ),

    // Yesterday
    ActivityDisplayItem(
      id: 'act_mock_4',
      title: 'Roshan added Fuel',
      subtitleAmount: '₹2,100',
      timestamp: 'Delhi · 8:45 PM',
      trailingText: '₹2,100',
      trailingColor: Color(0xFF111827),
      memberCount: 3,
      totalAmount: 2100.0,
      statusText: 'Fuel',
      statusColor: Color(0xFF111827),
      icon: Icons.local_gas_station_outlined,
      iconBgColor: Color(0xFFFFF4E6),
      iconColor: Color(0xFF1E1E1E),
      section: 'Yesterday',
      isSettlement: false,
      type: 'expense',
    ),
    ActivityDisplayItem(
      id: 'act_mock_5',
      title: 'Priya joined Delhi',
      subtitleAmount: null,
      timestamp: '10:15 AM',
      trailingText: null,
      trailingColor: null,
      memberCount: 4,
      totalAmount: 0.0,
      statusText: 'Joined',
      statusColor: AppColors.textSecondary,
      icon: Icons.person_add_outlined,
      iconBgColor: Color(0xFFF4F4F5),
      iconColor: Color(0xFF1E1E1E),
      section: 'Yesterday',
      isSettlement: false,
      type: 'member',
    ),
  ];
}
