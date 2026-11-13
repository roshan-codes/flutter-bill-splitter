import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_avatar_kit/flutter_avatar_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Bottom sheet allowing user to browse and pick any Memo avatar from flutter_avatar_kit.
/// Adheres to design.md Section 2, 3, 5, 6 & 8.
class MemoAvatarPickerSheet extends StatefulWidget {
  final int? initialIndex;
  final ValueChanged<int> onAvatarSelected;

  const MemoAvatarPickerSheet({
    super.key,
    this.initialIndex,
    required this.onAvatarSelected,
  });

  static Future<void> show(
    BuildContext context, {
    int? initialIndex,
    required ValueChanged<int> onAvatarSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemoAvatarPickerSheet(
        initialIndex: initialIndex,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  @override
  State<MemoAvatarPickerSheet> createState() => _MemoAvatarPickerSheetState();
}

class _MemoAvatarPickerSheetState extends State<MemoAvatarPickerSheet> {
  late int _selectedIndex;
  final int _totalMemos = AvatarAssets.count(AvatarType.memo);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxSheetHeight = mediaQuery.size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),

            // Header: Title & Subtitle + Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Avatar',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a memo avatar for your profile',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1, thickness: 1.0),

            // Scrollable Grid of 35 Memo Avatars
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
                itemCount: _totalMemos,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.surfaceSubtle : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card - 4),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AvatarWidget(
                            type: AvatarType.memo,
                            index: index,
                            size: 56,
                            shape: AvatarShape.circle,
                          ),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: AppColors.border, height: 1, thickness: 1.0),

            // Bottom Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: PlatformButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onAvatarSelected(_selectedIndex);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Set as Profile Avatar',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
