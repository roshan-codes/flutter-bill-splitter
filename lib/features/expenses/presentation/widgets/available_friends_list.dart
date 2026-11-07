import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// List of available friends with tap selection support and empty states.
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${filteredFriends.length} available',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredFriends.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                allFriends.isEmpty
                    ? 'No friends available in your list.\nAdd friends in the Friends tab.'
                    : 'No friends matching "$searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.18),
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.primaryDeep,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              friend.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : const Color(0xFFC4CDC3),
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
