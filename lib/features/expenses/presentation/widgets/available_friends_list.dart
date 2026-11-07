import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Neumorphic list of available friends with tap selection support and empty states.
class AvailableFriendsList extends StatelessWidget {
  final List<Friend> allFriends;
  final List<Friend> filteredFriends;
  final Set<int> selectedIndices;
  final String searchQuery;
  final ValueChanged<int> onFriendToggled;

  const AvailableFriendsList({
    super.key,
    required this.allFriends,
    required this.filteredFriends,
    required this.selectedIndices,
    required this.searchQuery,
    required this.onFriendToggled,
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
              'Friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${filteredFriends.length} available',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredFriends.isEmpty)
          FlutterNeumorphism(
            style: NeumorphicStyles.inset(borderRadius: 18, depth: 3),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                allFriends.isEmpty
                    ? 'No friends available in your list.\nAdd friends in the Friends tab.'
                    : 'No friends matching "$searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredFriends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              final originalIndex = allFriends.indexOf(friend);
              final isSelected = selectedIndices.contains(originalIndex);
              final initials = StringUtils.getInitials(friend.name);

              return InkWell(
                onTap: () => onFriendToggled(originalIndex),
                borderRadius: BorderRadius.circular(16),
                child: FlutterNeumorphism(
                  style: isSelected
                      ? NeumorphicStyles.inset(borderRadius: 16, depth: 3)
                      : NeumorphicStyles.card(borderRadius: 16, depth: 4),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      FlutterNeumorphism(
                        style: NeumorphicStyles.circle(
                          depth: 3,
                          color: isSelected ? AppColors.primary : AppColors.primaryLight,
                        ),
                        width: 42,
                        height: 42,
                        padding: EdgeInsets.zero,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.primaryDeep,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              friend.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primaryDeep : Colors.grey.shade400,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
