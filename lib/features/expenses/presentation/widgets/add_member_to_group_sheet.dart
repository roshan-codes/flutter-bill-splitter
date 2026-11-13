import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Bottom sheet to add/remove members from an existing group.
/// Adheres to design.md Section 6, 7 & 10.
class AddMemberToGroupSheet extends StatefulWidget {
  final Group group;
  final List<Friend> allFriends;
  final ValueChanged<List<Friend>> onMembersUpdated;

  const AddMemberToGroupSheet({
    super.key,
    required this.group,
    required this.allFriends,
    required this.onMembersUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Group group,
    required List<Friend> allFriends,
    required ValueChanged<List<Friend>> onMembersUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
      ),
      builder: (_) => AddMemberToGroupSheet(
        group: group,
        allFriends: allFriends,
        onMembersUpdated: onMembersUpdated,
      ),
    );
  }

  @override
  State<AddMemberToGroupSheet> createState() => _AddMemberToGroupSheetState();
}

class _AddMemberToGroupSheetState extends State<AddMemberToGroupSheet> {
  late final Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = {};
    for (int i = 0; i < widget.allFriends.length; i++) {
      final f = widget.allFriends[i];
      if (widget.group.members.any((m) => m.name == f.name || m.phone == f.phone)) {
        _selectedIndices.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Members of ${widget.group.name}',
              style: GoogleFonts.manrope(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.allFriends.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No friends in your list yet.\nAdd friends in the Friends tab.',
                  style: GoogleFonts.manrope(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.allFriends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, idx) {
                    final friend = widget.allFriends[idx];
                    final isSelected = _selectedIndices.contains(idx);
                    final initials = StringUtils.getInitials(friend.name);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                        child: Text(
                          initials,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      title: Text(
                        friend.name,
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        friend.phone,
                        style: GoogleFonts.manrope(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(idx);
                          } else {
                            _selectedIndices.add(idx);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
              ),
              onPressed: () {
                final updatedMembers = _selectedIndices.map((i) => widget.allFriends[i]).toList();
                widget.onMembersUpdated(updatedMembers);
                Navigator.pop(context);
              },
              child: Text(
                'Save Members',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
