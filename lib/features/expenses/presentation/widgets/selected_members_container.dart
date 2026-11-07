import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Rectangular container displaying selected members with 'x' remove badges.
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
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (selectedIndices.isNotEmpty)
              Text(
                '${selectedIndices.length} selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDeep,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderMedium,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                          fontWeight: FontWeight.w500,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
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
                          top: -5,
                          right: -5,
                          child: GestureDetector(
                            key: ValueKey('remove_selected_${friend.name}'),
                            onTap: () => onRemove(friendIndex),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
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
