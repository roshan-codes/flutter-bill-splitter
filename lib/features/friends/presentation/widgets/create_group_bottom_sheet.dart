import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Modal bottom sheet to create a new group with neumorphic UI styling.
class CreateGroupBottomSheet extends StatefulWidget {
  final List<Friend> availableFriends;
  final ValueChanged<Group> onGroupCreated;

  const CreateGroupBottomSheet({
    super.key,
    required this.availableFriends,
    required this.onGroupCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Friend> availableFriends,
    required ValueChanged<Group> onGroupCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CreateGroupBottomSheet(
        availableFriends: availableFriends,
        onGroupCreated: onGroupCreated,
      ),
    );
  }

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _selectedMemberIndices = {};

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMemberIndices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least 1 member for the group'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final gName = _groupNameController.text.trim();
      final selectedFriends = _selectedMemberIndices.map((i) => widget.availableFriends[i]).toList();
      final newGroup = Group(name: gName, members: selectedFriends);

      widget.onGroupCreated(newGroup);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 4, depth: 2),
                  width: 44,
                  height: 5,
                  padding: EdgeInsets.zero,
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Create New Group',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 16, depth: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: TextFormField(
                    controller: _groupNameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g. Goa Trip, Flatmates',
                      prefixIcon: Icon(Icons.groups_outlined, color: AppColors.primaryDeep),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter group name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Members',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedMemberIndices.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _selectedMemberIndices.isNotEmpty
                          ? AppColors.primaryDeep
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.availableFriends.isEmpty)
                FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 16, depth: 3),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'No friends added yet to add to group.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.availableFriends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final friend = widget.availableFriends[index];
                      final isSelected = _selectedMemberIndices.contains(index);
                      final initials = StringUtils.getInitials(friend.name);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedMemberIndices.remove(index);
                            } else {
                              _selectedMemberIndices.add(index);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterNeumorphism(
                          style: isSelected
                              ? NeumorphicStyles.inset(borderRadius: 16, depth: 3)
                              : NeumorphicStyles.card(borderRadius: 16, depth: 4),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected
                                    ? AppColors.primary
                                    : AppColors.primaryLight,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryDark
                                        : AppColors.primaryDeep,
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
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
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
                                color: isSelected ? AppColors.primaryDeep : Colors.grey.shade400,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FlutterNeumorphism(
                      style: NeumorphicStyles.primaryButton(borderRadius: 16, depth: 5),
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primaryDark,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Create Group', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
