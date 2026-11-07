import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';

/// Modal bottom sheet allowing users to select and import contacts into BillSplit.
class ImportContactsSheet extends StatefulWidget {
  final List<Friend> existingFriends;
  final ValueChanged<List<Friend>> onContactsImported;
  final List<Friend>? contactList;

  const ImportContactsSheet({
    super.key,
    required this.existingFriends,
    required this.onContactsImported,
    this.contactList,
  });

  /// Default contacts list from device contacts for selection.
  static const List<Friend> defaultDeviceContacts = [
    Friend(name: 'Rahul Sharma', phone: '+91 98201 12345'),
    Friend(name: 'Priya Patel', phone: '+91 98202 23456'),
    Friend(name: 'Amit Kumar', phone: '+91 98203 34567'),
    Friend(name: 'Sneha Verma', phone: '+91 98204 45678'),
    Friend(name: 'Rohan Deshmukh', phone: '+91 98205 56789'),
    Friend(name: 'Ananya Iyer', phone: '+91 98206 67890'),
    Friend(name: 'Vikram Malhotra', phone: '+91 98207 78901'),
    Friend(name: 'Tanvi Joshi', phone: '+91 98208 89012'),
  ];

  static Future<void> show(
    BuildContext context, {
    required List<Friend> existingFriends,
    required ValueChanged<List<Friend>> onContactsImported,
    List<Friend>? contactList,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ImportContactsSheet(
        existingFriends: existingFriends,
        onContactsImported: onContactsImported,
        contactList: contactList,
      ),
    );
  }

  @override
  State<ImportContactsSheet> createState() => _ImportContactsSheetState();
}

class _ImportContactsSheetState extends State<ImportContactsSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedPhones = {};
  String _searchQuery = '';

  late final List<Friend> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = widget.contactList ?? ImportContactsSheet.defaultDeviceContacts;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAlreadyAdded(Friend contact) {
    return widget.existingFriends.any(
      (f) =>
          f.phone.replaceAll(RegExp(r'\s+'), '') ==
              contact.phone.replaceAll(RegExp(r'\s+'), '') ||
          f.name.toLowerCase() == contact.name.toLowerCase(),
    );
  }

  void _toggleSelection(Friend contact) {
    if (_isAlreadyAdded(contact)) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedPhones.contains(contact.phone)) {
        _selectedPhones.remove(contact.phone);
      } else {
        _selectedPhones.add(contact.phone);
      }
    });
  }

  void _importSelected() {
    if (_selectedPhones.isEmpty) return;
    HapticFeedback.mediumImpact();

    final toImport = _contacts
        .where((c) => _selectedPhones.contains(c.phone) && !_isAlreadyAdded(c))
        .toList();

    widget.onContactsImported(toImport);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          toImport.length == 1
              ? 'Imported ${toImport.first.name} to Friends'
              : 'Imported ${toImport.length} contacts to Friends',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.phone.replaceAll(' ', '').contains(_searchQuery.replaceAll(' ', ''));
    }).toList();

    final availableFiltered =
        filteredContacts.where((c) => !_isAlreadyAdded(c)).toList();
    final allSelected = availableFiltered.isNotEmpty &&
        availableFiltered.every((c) => _selectedPhones.contains(c.phone));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
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

              // Header
              Row(
                children: [
                  FlutterNeumorphism(
                    style: NeumorphicStyles.circle(
                      depth: 4,
                      color: const Color(0xFFE0F2FE),
                    ),
                    width: 44,
                    height: 44,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.contacts_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Import from Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (availableFiltered.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (allSelected) {
                            _selectedPhones.clear();
                          } else {
                            _selectedPhones.addAll(
                                availableFiltered.map((c) => c.phone));
                          }
                        });
                      },
                      child: Text(
                        allSelected ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              FlutterNeumorphism(
                style: NeumorphicStyles.inset(borderRadius: 16, depth: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  color: AppColors.textSecondary,
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contacts list
              Expanded(
                child: filteredContacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No contacts match "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final isAdded = _isAlreadyAdded(contact);
                          final isSelected =
                              _selectedPhones.contains(contact.phone);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FlutterNeumorphism(
                              style: isSelected
                                  ? NeumorphicStyles.card(
                                      borderRadius: 16,
                                      depth: 4,
                                      color: const Color(0xFFF0FDF4),
                                    )
                                  : NeumorphicStyles.card(
                                      borderRadius: 16,
                                      depth: isAdded ? 1 : 4,
                                      color: isAdded
                                          ? const Color(0xFFF3F4F6)
                                          : AppColors.surface,
                                    ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              onTap: isAdded ? null : () => _toggleSelection(contact),
                              child: Row(
                                children: [
                                  // Contact avatar
                                  FlutterNeumorphism(
                                    style: NeumorphicStyles.circle(
                                      depth: 3,
                                      color: isAdded
                                          ? const Color(0xFFE5E7EB)
                                          : const Color(0xFFE0F2FE),
                                    ),
                                    width: 40,
                                    height: 40,
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: Text(
                                        StringUtils.getInitials(contact.name),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isAdded
                                              ? AppColors.textSecondary
                                              : const Color(0xFF0369A1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Name and phone
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: isAdded
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          contact.phone,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Checkbox or Added badge
                                  if (isAdded)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Added',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  else
                                    Semantics(
                                      label:
                                          '${isSelected ? "Deselect" : "Select"} ${contact.name}',
                                      checked: isSelected,
                                      child: FlutterNeumorphism(
                                        style: isSelected
                                            ? NeumorphicStyles.circle(
                                                depth: 3,
                                                color: AppColors.primary,
                                              )
                                            : NeumorphicStyles.circle(
                                                depth: 2,
                                                color: AppColors.surface,
                                              ),
                                        width: 28,
                                        height: 28,
                                        padding: EdgeInsets.zero,
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 16,
                                                color: AppColors.primaryDeep,
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // Import Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _selectedPhones.isEmpty ? null : _importSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.35),
                    foregroundColor: AppColors.primaryDeep,
                    elevation: _selectedPhones.isEmpty ? 0 : 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _selectedPhones.isEmpty
                        ? 'Select Contacts to Import'
                        : _selectedPhones.length == 1
                            ? 'Import 1 Contact'
                            : 'Import ${_selectedPhones.length} Contacts',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
