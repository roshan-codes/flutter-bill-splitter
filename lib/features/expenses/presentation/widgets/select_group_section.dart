import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/shared/widgets/squircle_avatar.dart';

/// Horizontally scrollable neumorphic group selector section with member avatars.
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
            InkWell(
              onTap: onCreateGroupPressed,
              borderRadius: BorderRadius.circular(20),
              child: FlutterNeumorphism(
                style: NeumorphicStyles.circle(depth: 4),
                width: 38,
                height: 38,
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.add,
                  color: AppColors.amber,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 176,
          child: groups.isEmpty
              ? FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 22, depth: 3),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: const Center(
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

                    return InkWell(
                      onTap: () => onGroupSelected(index),
                      borderRadius: BorderRadius.circular(26),
                      child: FlutterNeumorphism(
                        style: isSelected
                            ? NeumorphicStyles.inset(borderRadius: 26, depth: 4)
                            : NeumorphicStyles.card(borderRadius: 26, depth: 6),
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
                                          isNeumorphic: false,
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
                                  FlutterNeumorphism(
                                    style: NeumorphismStyle(
                                      color: AppColors.amber,
                                      borderRadius: 10,
                                      depth: 4,
                                      lightShadow: Colors.white.withOpacity(0.6),
                                      darkShadow: const Color(0xFFC78F1A),
                                    ),
                                    width: 32,
                                    height: 32,
                                    padding: EdgeInsets.zero,
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
