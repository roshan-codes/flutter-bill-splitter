import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/add_member_to_group_sheet.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/available_friends_list.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/search_name_group_bar.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/select_group_section.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/selected_members_container.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/create_group_bottom_sheet.dart';

/// Full-screen view for Adding an Expense & Splitting between groups/friends.
class AddExpenseScreen extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;

  const AddExpenseScreen({
    super.key,
    required this.friends,
    required this.groups,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _selectedFriendIndices = {};
  int? _selectedGroupIndex;
  late List<Group> _availableGroups;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _availableGroups = List.from(widget.groups);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateGroupModal() {
    CreateGroupBottomSheet.show(
      context,
      availableFriends: widget.friends,
      onGroupCreated: (newGroup) {
        setState(() {
          _availableGroups.add(newGroup);
          _selectedGroupIndex = _availableGroups.length - 1;
          _groupNameController.text = newGroup.name;
          _selectedFriendIndices.clear();
          for (final f in newGroup.members) {
            final fIdx = widget.friends.indexOf(f);
            if (fIdx != -1) _selectedFriendIndices.add(fIdx);
          }
        });
      },
    );
  }

  void _openAddMemberToGroup(int groupIndex) {
    final group = _availableGroups[groupIndex];
    AddMemberToGroupSheet.show(
      context,
      group: group,
      allFriends: widget.friends,
      onMembersUpdated: (updatedMembers) {
        setState(() {
          _availableGroups[groupIndex] = group.copyWith(members: updatedMembers);
          if (_selectedGroupIndex == groupIndex) {
            _selectedFriendIndices.clear();
            for (final m in updatedMembers) {
              final idx = widget.friends.indexOf(m);
              if (idx != -1) _selectedFriendIndices.add(idx);
            }
          }
        });
      },
    );
  }

  void _onGroupSelected(int index) {
    final group = _availableGroups[index];
    setState(() {
      _selectedGroupIndex = index;
      _groupNameController.text = group.name;

      if (group.members.isNotEmpty) {
        _selectedFriendIndices.clear();
        for (final member in group.members) {
          final found = widget.friends.indexWhere(
            (f) => f.name == member.name || f.phone == member.phone,
          );
          if (found != -1) {
            _selectedFriendIndices.add(found);
          }
        }
      }
    });
  }

  void _onContinuePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFriendIndices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least 1 friend or group member to continue'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final gName = _groupNameController.text.trim();
      final selectedFriends = _selectedFriendIndices.map((i) => widget.friends[i]).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SplitDetailScreen(
            groupName: gName,
            members: selectedFriends,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = widget.friends.where((f) {
      if (_searchQuery.isEmpty) return true;
      if (f.name.toLowerCase().contains(_searchQuery) || f.phone.toLowerCase().contains(_searchQuery)) {
        return true;
      }
      final matchingGroups = _availableGroups.where((g) => g.name.toLowerCase().contains(_searchQuery));
      return matchingGroups.any((g) => g.members.any((m) => m.name == f.name || m.phone == f.phone));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: FlutterNeumorphism(
                style: NeumorphicStyles.circle(depth: 4),
                width: 38,
                height: 38,
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Add & Split Expense',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Group Name Field
                const Text(
                  'Group Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 18, depth: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: TextFormField(
                    controller: _groupNameController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Goa Trip, Dinner, Flat Rent',
                      prefixIcon: Icon(Icons.groups_outlined, color: AppColors.primaryDeep),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter group name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Selected Person Container
                SelectedMembersContainer(
                  allFriends: widget.friends,
                  selectedIndices: _selectedFriendIndices,
                  onRemove: (idx) {
                    setState(() {
                      _selectedFriendIndices.remove(idx);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 3. Group List ("Select group")
                SelectGroupSection(
                  groups: _availableGroups,
                  selectedGroupIndex: _selectedGroupIndex,
                  currentGroupName: _groupNameController.text,
                  onGroupSelected: _onGroupSelected,
                  onCreateGroupPressed: _showCreateGroupModal,
                  onAddMemberPressed: _openAddMemberToGroup,
                ),
                const SizedBox(height: 24),

                // 4. Search by Group or Name Option
                SearchNameGroupBar(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  onSearchPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 5. Friends List
                AvailableFriendsList(
                  allFriends: widget.friends,
                  filteredFriends: filteredFriends,
                  selectedIndices: _selectedFriendIndices,
                  searchQuery: _searchQuery,
                  onFriendToggled: (origIdx) {
                    setState(() {
                      if (_selectedFriendIndices.contains(origIdx)) {
                        _selectedFriendIndices.remove(origIdx);
                      } else {
                        _selectedFriendIndices.add(origIdx);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      // 6. Continue Button: Fixed at bottom, does not react to scrolling
      bottomNavigationBar: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FlutterNeumorphism(
              style: NeumorphicStyles.primaryButton(borderRadius: 18, depth: 6),
              padding: EdgeInsets.zero,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primaryDark,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _onContinuePressed,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
