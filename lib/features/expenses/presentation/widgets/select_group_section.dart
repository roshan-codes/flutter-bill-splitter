import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';
import 'package:flutter_bill_splitter/shared/widgets/squircle_avatar.dart';

/// Horizontally scrollable platform-adaptive group selector section with member avatars.
class SelectGroupSection extends StatelessWidget {
  final List<Group> groups;
  final int? selectedGroupIndex;
  final String currentGroupName;
  final ValueChanged<int> onGroupSelected;
  final VoidCallback onCreateGroupPressed;
  final ValueChanged<int> onAddMemberPressed;

  const SelectGroupSection({
    super.key,
    required this.groups,
    required this.selectedGroupIndex,
    required this.currentGroupName,
    required this.onGroupSelected,
    required this.onCreateGroupPressed,
    required this.onAddMemberPressed,
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
              'Select group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            PlatformCircleButton(
              size: 38,
              onTap: onCreateGroupPressed,
              tooltip: 'Create Group',
              child: const Icon(
                Icons.add,
                color: AppColors.amber,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 176,
          child: groups.isEmpty
              ? const PlatformInsetContainer(
                  borderRadius: 22,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No groups created yet.\nTap + above to create a group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isSelected = selectedGroupIndex == index ||
                        currentGroupName.trim() == group.name;

                    return PlatformCard(
                      borderRadius: 22,
                      elevation: isSelected ? 2 : 1,
                      color: isSelected ? AppColors.primaryLight.withOpacity(0.35) : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      onTap: () => onGroupSelected(index),
                      width: 250,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryDeep,
                                  size: 18,
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 38,
                            child: group.members.isEmpty
                                ? const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'No members yet',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: group.members.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                                    itemBuilder: (context, mIdx) {
                                      final member = group.members[mIdx];
                                      return SquircleAvatar(
                                        name: member.name,
                                        avatarUrl: member.avatarUrl,
                                        size: 36,
                                        borderRadius: 14,
                                      );
                                    },
                                  ),
                          ),
                          InkWell(
                            onTap: () => onAddMemberPressed(index),
                            borderRadius: BorderRadius.circular(10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.amber,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.amber.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.primaryDark,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Add member',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
