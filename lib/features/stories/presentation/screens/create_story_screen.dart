import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/import_contacts_sheet.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// Screen 1 from design: High-fidelity "Create Story" form matching the mockup
/// - Header: Back button `<` + Title "Create Story"
/// - Field 1: Story name (icon + hint "Goa")
/// - Field 2: Description (optional) (hint "Stay, food, travel, groceries etc.")
/// - Field 3: Add members card (icon + horizontal avatars list [R, S, Roshan] + `+` button)
/// - Bottom button: "Create Story →" (black pill)
class CreateStoryScreen extends StatefulWidget {
  final String? initialTitle;
  final List<String>? initialMembers;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const CreateStoryScreen({
    super.key,
    this.initialTitle,
    this.initialMembers,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late final String _storyId;
  String _creatorName = 'You';
  String _selectedCoverEmoji = '🌴';
  final List<String> _selectedMembers = [];

  static const List<String> _popularEmojis = [
    '🌴', '✈️', '🏖️', '🏔️', '🎉', '🍕', '🚗', '⛺', '🏠', '🎬', '☕', '🍻'
  ];

  @override
  void initState() {
    super.initState();
    _storyId = 'story_${DateTime.now().millisecondsSinceEpoch}';
    _nameController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController();

    if (widget.initialMembers != null && widget.initialMembers!.isNotEmpty) {
      _selectedMembers.addAll(widget.initialMembers!);
    } else {
      _selectedMembers.add(_creatorName);
    }

    _initCreator();
  }

  Future<void> _initCreator() async {
    final authName = SupabaseService.userDisplayName;
    final savedName =
        await StorageService.instance.getString('user_profile_name');
    final name = authName ?? savedName;
    if (name != null && name.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          final oldName = _creatorName;
          _creatorName = name.trim();
          final idx = _selectedMembers.indexWhere((m) => m == oldName || m == 'You');
          if (idx != -1) {
            _selectedMembers[idx] = _creatorName;
          } else if (!_selectedMembers.contains(_creatorName)) {
            _selectedMembers.insert(0, _creatorName);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isMemberAlreadySelected(String name) {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty) return true;
    if (clean == 'you' || clean == _creatorName.toLowerCase().trim()) {
      return true;
    }
    return _selectedMembers.any((m) {
      final cleanM = m.toLowerCase().trim();
      if (cleanM == clean) return true;
      if (cleanM == 'you' && clean == _creatorName.toLowerCase().trim()) {
        return true;
      }
      final mFirst = cleanM.split(' ').first;
      final cFirst = clean.split(' ').first;
      if (mFirst == cFirst &&
          mFirst.length > 2 &&
          (cleanM.length == mFirst.length || clean.length == cFirst.length)) {
        return true;
      }
      return false;
    });
  }

  void _openContactsPicker([BuildContext? modalContext]) {
    if (modalContext != null && Navigator.of(modalContext).canPop()) {
      Navigator.of(modalContext).pop();
    }
    ImportContactsSheet.show(
      context,
      existingFriends: FriendsRepository.instance.friends,
      onContactsImported: (imported) {
        setState(() {
          for (final c in imported) {
            final name = c.name.trim();
            if (name.isNotEmpty && !_isMemberAlreadySelected(name)) {
              _selectedMembers.add(name);
            }
            if (!FriendsRepository.instance.friends
                .any((f) => f.name.toLowerCase() == name.toLowerCase())) {
              FriendsRepository.instance.addFriend(c);
            }
          }
        });
      },
    );
  }

  void _copyInviteLink() {
    final inviteUrl = InviteService.buildInviteUrl(_storyId);
    Clipboard.setData(ClipboardData(text: inviteUrl));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Invite link copied! Share with friends to join after login.',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddMemberModal() {
    HapticFeedback.selectionClick();
    final friends = FriendsRepository.instance.friends;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Members',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add friends from contacts, enter manually, or share invite link.',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Option 1: Add from Contacts
                  InkWell(
                    onTap: () => _openContactsPicker(ctx),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.contacts_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add from Contacts',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Import friends from your phone contacts',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF9CA3AF), size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 2: Invite via Link
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.link_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invite via Link',
                                style: GoogleFonts.manrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF14532D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Friends join story after Google login',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(76, 36),
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: Text(
                            'Copy',
                            style: GoogleFonts.manrope(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            _copyInviteLink();
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option 3: Add Manually
                  Text(
                    'Add Manually',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.manrope(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter friend name...',
                            hintStyle: GoogleFonts.manrope(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF111111), width: 1.5),
                            ),
                          ),
                          onSubmitted: (val) {
                            final name = val.trim();
                            if (name.isNotEmpty &&
                                !_isMemberAlreadySelected(name)) {
                              setState(() {
                                _selectedMembers.add(name);
                              });
                              if (!FriendsRepository.instance.friends.any(
                                  (f) =>
                                      f.name.toLowerCase() ==
                                      name.toLowerCase())) {
                                FriendsRepository.instance
                                    .addFriend(Friend(name: name, phone: ''));
                              }
                              textController.clear();
                              setModalState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(64, 46),
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final name = textController.text.trim();
                          if (name.isNotEmpty &&
                              !_isMemberAlreadySelected(name)) {
                            setState(() {
                              _selectedMembers.add(name);
                            });
                            if (!FriendsRepository.instance.friends.any((f) =>
                                f.name.toLowerCase() == name.toLowerCase())) {
                              FriendsRepository.instance
                                  .addFriend(Friend(name: name, phone: ''));
                            }
                            textController.clear();
                            setModalState(() {});
                          }
                        },
                        child: Text(
                          'Add',
                          style:
                              GoogleFonts.manrope(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  // Option 4: Existing Friends filter chips
                  if (friends.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Existing Friends',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: friends.map((f) {
                        final isSelected = _selectedMembers.any(
                            (m) => m.toLowerCase().trim() == f.name.toLowerCase().trim());
                        return FilterChip(
                          label: Text(f.name),
                          selected: isSelected,
                          selectedColor: const Color(0xFF111111),
                          checkmarkColor: Colors.white,
                          labelStyle: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                          onSelected: (selected) {
                            if (!selected &&
                                f.name.toLowerCase().trim() ==
                                    _creatorName.toLowerCase().trim()) {
                              return;
                            }
                            setState(() {
                              if (selected) {
                                if (!_isMemberAlreadySelected(f.name)) {
                                  _selectedMembers.add(f.name);
                                }
                              } else {
                                _selectedMembers.removeWhere((m) =>
                                    m.toLowerCase().trim() ==
                                    f.name.toLowerCase().trim());
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createStory() {
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Mumbai Trip';
    final desc = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Trip, stay, food, travel etc.';

    final now = DateTime.now();

    final authUserId = SupabaseService.currentUser?.id;
    String? localGuestId = StorageService.instance.getStringSync('local_unique_device_user_id');
    if (localGuestId == null || localGuestId.isEmpty) {
      localGuestId = 'user_creator_${DateTime.now().millisecondsSinceEpoch}';
      StorageService.instance.setString('local_unique_device_user_id', localGuestId);
    }
    final currentUserId = (authUserId != null && authUserId.isNotEmpty) ? authUserId : localGuestId;

    final profileName = SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
    final rawCreator = _creatorName.trim().isNotEmpty && _creatorName.trim().toLowerCase() != 'you'
        ? _creatorName.trim()
        : (profileName?.trim().isNotEmpty == true ? profileName!.trim() : 'Roshan');
    final cleanCurrentName = rawCreator
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .trim();
    final currentUserName = cleanCurrentName.isNotEmpty ? cleanCurrentName : 'Roshan';

    // Build member list: creator is guaranteed to be Member #1 with role 'creator'
    final List<StoryMember> rawMembers = [];

    // 1. Add Creator
    rawMembers.add(
      StoryMember(
        userId: currentUserId,
        name: currentUserName,
        role: 'creator',
        avatar: SupabaseService.resolvedUserAvatar,
        joinedAt: now.toIso8601String(),
      ),
    );

    // 2. Add other selected members with strict deduplication
    final cleanCreator = currentUserName.toLowerCase();
    final Set<String> seenNames = {cleanCreator, 'you'};
    final Set<String> seenUserIds = {currentUserId};

    for (final rawName in _selectedMembers) {
      final mName = rawName.trim();
      final clean = mName.toLowerCase();
      if (clean.isEmpty) continue;
      if (seenNames.contains(clean)) continue;

      final mFirst = clean.split(' ').first;
      final cFirst = cleanCreator.split(' ').first;
      if (mFirst == cFirst && mFirst.length > 2) continue;

      final generatedId = 'user_${clean.replaceAll(' ', '_')}';
      if (seenUserIds.contains(generatedId)) continue;

      seenNames.add(clean);
      seenUserIds.add(generatedId);

      rawMembers.add(
        StoryMember(
          userId: generatedId,
          name: mName,
          avatar: AvatarResolver.getDefaultAvatarForName(mName),
          role: 'member',
          joinedAt: now.toIso8601String(),
        ),
      );
    }

    final membersList =
        Story.deduplicateMembers(rawMembers, creatorId: currentUserId);

    final balances = membersList.map((m) {
      return StoryMemberBalance(
        userId: m.userId,
        name: m.name,
        totalPaid: 0.0,
        totalShare: 0.0,
        netBalance: 0.0,
        status: 'settled',
      );
    }).toList();

    final newStory = Story(
      storyId: _storyId,
      title: name,
      description: desc,
      coverEmoji: _selectedCoverEmoji,
      currency: 'INR',
      status: 'active',
      createdBy: currentUserId,
      createdAt: now.toIso8601String(),
      startDate: null,
      endDate: null,
      members: membersList,
      summary: StorySummary(
        totalExpenses: 0.0,
        totalSettled: 0.0,
        pendingAmount: 0.0,
        memberCount: membersList.length,
        expenseCount: 0,
      ),
      expenses: const [],
      memberBalances: balances,
      settlements: const [],
    );

    StoryRepository.instance.addStory(newStory);

    Navigator.of(context).pushReplacement(
      AppTransitions.sharedAxisRoute(
        type: SharedAxisTransitionType.horizontal,
        duration: AppMotion.normal,
        builder: (context) => SplitDetailScreen(
          groupName: name,
          members:
              membersList.map((m) => Friend(name: m.name, phone: '')).toList(),
          story: newStory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      message: 'Back',
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xFFE5E7EB), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 26,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),

            // Form Title: "Create Story"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create Story',
                  style: GoogleFonts.manrope(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111111),
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ),

            // Scrollable Form Fields
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 0: Cover Icon
                    Text(
                      'Cover Icon',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularEmojis.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final emoji = _popularEmojis[index];
                          final isSelected = emoji == _selectedCoverEmoji;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCoverEmoji = emoji);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8EEFF)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF5B4DFF)
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.025),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Field 1: Story name
                    Text(
                      'Story name',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFFEAEAEF), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _selectedCoverEmoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111111),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Mumbai Trip',
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Field 2: Description (optional)
                    Text(
                      'Description (optional)',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFFEAEAEF), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TextField(
                          controller: _descriptionController,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111111),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Trip, stay, food, travel etc.',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Field 3: Add members
                    Text(
                      'Add members',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFFEAEAEF), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline_rounded,
                            size: 22,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final member in _selectedMembers) ...[
                                    _buildMemberAvatarChip(member),
                                    const SizedBox(width: 10),
                                  ],
                                  // Add member '+' button
                                  GestureDetector(
                                    onTap: _showAddMemberModal,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 20,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom "Create Story →" Black Pill Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _createStory,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Story',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatarChip(String name) {
    final isMe = name.toLowerCase().trim() == _creatorName.toLowerCase().trim() ||
        name.trim() == 'You';

    return AppAvatar(
      size: 40,
      name: name,
      avatarUrl: AvatarResolver.getDefaultAvatarForName(name),
      isCurrentUser: isMe,
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      backgroundColor: Colors.white,
      textColor: Colors.white,
      fontSize: 15,
    );
  }
}
