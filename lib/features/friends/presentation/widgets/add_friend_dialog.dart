import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Neumorphic Dialog to input a new friend's name and mobile number.
class AddFriendDialog extends StatefulWidget {
  final ValueChanged<Friend> onFriendAdded;

  const AddFriendDialog({
    super.key,
    required this.onFriendAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Friend> onFriendAdded,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AddFriendDialog(onFriendAdded: onFriendAdded),
    );
  }

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final friend = Friend(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      widget.onFriendAdded(friend);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      title: Row(
        children: [
          FlutterNeumorphism(
            style: NeumorphicStyles.circle(
              depth: 4,
              color: AppColors.primaryLight,
            ),
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primaryDeep,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add Friend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterNeumorphism(
              style: NeumorphicStyles.inset(borderRadius: 16, depth: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Friend Name',
                  hintText: 'Enter name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryDeep),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            FlutterNeumorphism(
              style: NeumorphicStyles.inset(borderRadius: 16, depth: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter mobile no',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryDeep),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
          ),
        ),
        FlutterNeumorphism(
          style: NeumorphicStyles.primaryButton(borderRadius: 14, depth: 5),
          padding: EdgeInsets.zero,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primaryDark,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _submit,
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
