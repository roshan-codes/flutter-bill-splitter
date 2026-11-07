import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Neumorphic rectangular container displaying selected members with 'x' remove badges.
class SelectedMembersContainer extends StatelessWidget {
  final List<Friend> allFriends;
  final Set<int> selectedIndices;
  final ValueChanged<int> onRemove;

  const SelectedMembersContainer({
    super.key,
    required this.allFriends,
    required this.selectedIndices,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Selected Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            if (selectedIndices.isNotEmpty)
              Text(
                '${selectedIndices.length} selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeep,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        FlutterNeumorphism(
          style: selectedIndices.isEmpty
              ? NeumorphicStyles.inset(borderRadius: 24, depth: 4)
              : NeumorphicStyles.card(borderRadius: 24, depth: 5),
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: selectedIndices.isEmpty
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select friends below to add them here',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedIndices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (context, idx) {
                    final friendIndex = selectedIndices.elementAt(idx);
                    final friend = allFriends[friendIndex];
                    final initials = StringUtils.getInitials(friend.name);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FlutterNeumorphism(
                          style: NeumorphicStyles.card(
                            borderRadius: 20,
                            depth: 4,
                            color: AppColors.primaryLight,
                          ),
                          width: 72,
                          height: 72,
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    friend.avatarUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallback(initials),
                                  )
                                : _buildFallback(initials),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            key: ValueKey('remove_selected_${friend.name}'),
                            onTap: () => onRemove(friendIndex),
                            child: FlutterNeumorphism(
                              style: NeumorphicStyles.circle(
                                depth: 3,
                                color: AppColors.surface,
                              ),
                              width: 26,
                              height: 26,
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textPrimary,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFallback(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryDeep,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}
