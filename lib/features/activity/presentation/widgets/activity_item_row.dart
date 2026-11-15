import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';

/// Single row item representing an activity entry inside an activity section card.
/// Matches design mockup (media_1794729268088_39ebec66.jpg).
class ActivityItemRow extends StatelessWidget {
  final ActivityDisplayItem item;
  final VoidCallback? onTap;

  const ActivityItemRow({
    super.key,
    required this.item,
    this.onTap,
  });

  String _formatAmount(double amount) {
    if (amount.truncateToDouble() == amount) {
      final parts = amount.toInt().toString().replaceAllMapped(
            RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '₹$parts';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final hasMockupStyle = item.subtitleAmount != null ||
        item.timestamp != null ||
        item.trailingText != null;

    return InkWell(
      onTap: onTap ??
          () {
            HapticFeedback.lightImpact();
            if (item.splitActivity != null) {
              ActivityDetailSheet.show(context, item.splitActivity!);
            }
          },
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Squircle Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Center Title & Subtitles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (hasMockupStyle) ...[
                        if (item.subtitleAmount != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitleAmount!,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                        if (item.timestamp != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.timestamp!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 3),
                        Text(
                          '${item.memberCount} members',
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Trailing Amount & Status
                if (hasMockupStyle) ...[
                  if (item.trailingText != null)
                    Text(
                      item.trailingText!,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: item.trailingColor ?? const Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(item.totalAmount),
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.statusText,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: item.statusColor,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            if (item.splitActivity != null &&
                item.splitActivity!.settlements.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.primaryDeep,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.splitActivity!.settlements.first.from.name} pays ${_formatAmount(item.splitActivity!.settlements.first.amount)} to ${item.splitActivity!.settlements.first.to.name}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatAmount(item.splitActivity!.sharePerPerson)} / person',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
