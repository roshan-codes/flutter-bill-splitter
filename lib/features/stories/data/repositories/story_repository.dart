import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/constants/app_constants.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';

/// Repository managing group expense stories backed solely by Supabase Cloud Database.
class StoryRepository extends ChangeNotifier {
  static final StoryRepository instance = StoryRepository();

  StoryRepository({StorageService? storageService});

  final List<Story> _stories = [];

  List<Story> get stories => List.unmodifiable(_stories);

  /// Initializes stories directly from Supabase Cloud Database.
  Future<void> init() async {
    try {
      await _syncFromSupabase();
      await _seedSampleStoryIfFirstTime();
      final currentAvatar = SupabaseService.resolvedUserAvatar;
      if (currentAvatar != null) {
        _applyAvatarToUserMembers(currentAvatar);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('StoryRepository init error: $e');
    }
  }

  /// Adds a sample starter story for first-time users so they can explore TTMM immediately.
  /// Users can edit or delete this story at any time.
  Future<void> _seedSampleStoryIfFirstTime() async {
    try {
      final alreadySeeded = await StorageService.instance
              .getBool(AppConstants.keyHasSeededSampleStory) ??
          false;
      if (!alreadySeeded && _stories.isEmpty) {
        final sampleStory = Story.sampleGoaTrip();
        _stories.add(sampleStory);
        await StorageService.instance
            .setBool(AppConstants.keyHasSeededSampleStory, true);
        if (SupabaseService.currentUser != null) {
          await SupabaseService.saveStory(sampleStory);
        }

        // Seed corresponding sample activities so Activity & Recent Expenses show realistic data
        for (final exp in sampleStory.expenses) {
          final act = SplitActivity(
            id: exp.expenseId,
            groupName: sampleStory.title,
            expenseTitle: exp.title,
            totalAmount: exp.amount,
            sharePerPerson: exp.amount /
                (sampleStory.members.isEmpty ? 1 : sampleStory.members.length),
            members: sampleStory.members
                .map((m) => Friend(name: m.name, phone: ''))
                .toList(),
            memberExpenses: {exp.paidBy: exp.amount},
            settlements: const [],
            timestamp: DateTime.tryParse(exp.date) ?? DateTime.now(),
          );
          ActivityRepository.instance.recordActivity(act);
        }
      }
    } catch (e) {
      debugPrint('StoryRepository sample seed error: $e');
    }
  }

  Future<void> _syncFromSupabase() async {
    try {
      final remote = await SupabaseService.fetchStories();
      if (remote.isNotEmpty) {
        for (final r in remote) {
          final idx = _stories.indexWhere((s) => s.storyId == r.storyId);
          if (idx != -1) {
            _stories[idx] = r;
          } else {
            _stories.add(r);
          }
        }
      }
      final currentAvatar = SupabaseService.resolvedUserAvatar;
      if (currentAvatar != null) {
        _applyAvatarToUserMembers(currentAvatar);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase story sync note: $e');
    }
  }

  /// Retrieves a story by its unique identifier.
  Story? getStoryById(String storyId) {
    try {
      return _stories.firstWhere((s) => s.storyId == storyId);
    } catch (_) {
      return null;
    }
  }

  /// Public sync method for refreshing all stories from Supabase.
  Future<void> syncAllFromSupabase() async {
    await _syncFromSupabase();
  }

  /// Pulls the latest version of a specific story from Supabase and updates in-memory state.
  Future<Story?> refreshStory(String storyId) async {
    try {
      final remote = await SupabaseService.fetchStoryById(storyId);
      if (remote != null) {
        final idx = _stories.indexWhere((s) => s.storyId == storyId);
        if (idx != -1) {
          _stories[idx] = remote;
        } else {
          _stories.insert(0, remote);
        }
        notifyListeners();
        return remote;
      }
    } catch (e) {
      debugPrint('StoryRepository refreshStory error: $e');
    }
    return getStoryById(storyId);
  }

  static final Set<String> _joiningStoryIds = {};

  /// Adds the current authenticated user to an existing story via an invite link.
  Future<Story?> joinStoryWithCurrentUser(String storyId) async {
    if (_joiningStoryIds.contains(storyId)) {
      return getStoryById(storyId);
    }
    _joiningStoryIds.add(storyId);

    try {
      // 1. Fetch story by ID (prefer freshest remote copy from Supabase, fallback to local)
      var story = await SupabaseService.fetchStoryById(storyId);
      story ??= getStoryById(storyId);
      if (story == null) return null;

      final authUserId = SupabaseService.currentUser?.id;
      final rawUserName = SupabaseService.userDisplayName ??
          await StorageService.instance.getString('user_profile_name') ??
          'Friend';
      final cleanUserName = rawUserName
          .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
          .trim();
      final effectiveUserName =
          cleanUserName.isNotEmpty ? cleanUserName : 'Friend';
      final userAvatar = SupabaseService.resolvedUserAvatar;

      // Stable unique device ID for unauthenticated / guest users
      String? localGuestId = await StorageService.instance
          .getString('local_unique_device_user_id');
      if (localGuestId == null || localGuestId.isEmpty) {
        localGuestId =
            'user_guest_${DateTime.now().millisecondsSinceEpoch}_${cleanUserName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
        await StorageService.instance
            .setString('local_unique_device_user_id', localGuestId);
      }
      final currentDeviceUserId =
          (authUserId != null && authUserId.isNotEmpty)
              ? authUserId
              : localGuestId;

      final cleanUser = effectiveUserName.toLowerCase().trim();
      final uFirst = cleanUser.split(' ').first;

      // Check if user is already a member (or matches an existing manual member slot)
      final existingIndex = story.members.indexWhere((m) {
        final cleanM = m.name
            .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
            .toLowerCase()
            .trim();
        final mId = m.userId.trim();

        // 1. Authenticated user ID matches
        if (authUserId != null &&
            authUserId.isNotEmpty &&
            mId.isNotEmpty &&
            mId == authUserId) {
          return true;
        }

        // 2. Exact normalized name matches
        if (cleanUser.isNotEmpty && cleanM == cleanUser) return true;

        // 3. 'You' matches current user (claims existing 'You' slot instead of creating duplicate)
        if (cleanM == 'you') {
          return true;
        }

        // 4. First name matches full name (e.g. "Roshan" and "Roshan Badwaik")
        final mFirst = cleanM.split(' ').first;
        if (mFirst == uFirst &&
            mFirst.length > 2 &&
            (cleanM.length == mFirst.length || cleanUser.length == uFirst.length)) {
          return true;
        }

        // 5. Manual generated ID matches: user_roshan matches Roshan
        if (mId == 'user_${cleanUser.replaceAll(' ', '_')}') return true;

        return false;
      });

      if (existingIndex != -1) {
        // User is already a member or has a pre-existing manual member slot.
        // Claim and upgrade their existing slot with real authenticated userId and avatar.
        final existing = story.members[existingIndex];

        // Ensure targetUserId does not clash with another member in the story
        final isIdAlreadyUsedByOther = story.members
            .asMap()
            .entries
            .any((e) => e.key != existingIndex && e.value.userId == currentDeviceUserId);

        final targetUserId = isIdAlreadyUsedByOther
            ? (existing.userId.isNotEmpty
                ? existing.userId
                : 'user_${cleanUser.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch % 10000}')
            : currentDeviceUserId;

        final updatedMember = StoryMember(
          userId: targetUserId,
          name: (existing.name.toLowerCase().trim() == 'you' ||
                  cleanUser.length > existing.name.length)
              ? effectiveUserName
              : existing.name
                  .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
                  .trim(),
          avatar: userAvatar ??
              existing.avatar ??
              AvatarResolver.getDefaultAvatarForName(effectiveUserName),
          role: existing.role,
          joinedAt: existing.joinedAt.isNotEmpty
              ? existing.joinedAt
              : DateTime.now().toIso8601String(),
        );

        final updatedMembers = List<StoryMember>.from(story.members);
        updatedMembers[existingIndex] = updatedMember;

        final updatedBalances = story.memberBalances.map((b) {
          final bClean = b.name
              .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
              .toLowerCase()
              .trim();
          final exClean = existing.name
              .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
              .toLowerCase()
              .trim();
          if (b.userId == existing.userId || bClean == exClean) {
            return StoryMemberBalance(
              userId: updatedMember.userId,
              name: updatedMember.name,
              totalPaid: b.totalPaid,
              totalShare: b.totalShare,
              netBalance: b.netBalance,
              status: b.status,
            );
          }
          return b;
        }).toList();

        final updatedStory = story.copyWith(
          members: Story.deduplicateMembers(updatedMembers),
          memberBalances: Story.deduplicateBalances(updatedBalances),
        );

        await updateStory(updatedStory);
        return updatedStory;
      }

      // Truly new member joining
      final isIdUsed =
          story.members.any((m) => m.userId == currentDeviceUserId);
      final newMemberId = isIdUsed
          ? 'user_${cleanUser.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch % 10000}'
          : currentDeviceUserId;

      final now = DateTime.now();
      final newMember = StoryMember(
        userId: newMemberId,
        name: effectiveUserName,
        avatar: userAvatar ??
            AvatarResolver.getDefaultAvatarForName(effectiveUserName),
        role: 'member',
        joinedAt: now.toIso8601String(),
      );

      final updatedMembers =
          Story.deduplicateMembers([...story.members, newMember]);

      final currentStory = story;
      final previousMembers = currentStory.members;
      final previousMemberCount = previousMembers.length;
      final updatedExpenses = currentStory.expenses.map((expense) {
        final isEqual = expense.splitType == 'equal' ||
            (currentStory.splitMethod == 'equal' &&
                expense.splitType != 'exact' &&
                expense.splitType != 'percentage' &&
                expense.splitType != 'shares');
        if (!isEqual) return expense;

        final isGroupWide = expense.participants.isEmpty ||
            expense.participants.length >= previousMemberCount ||
            previousMembers.every((pm) => expense.participants.any(
                (p) =>
                    p == pm.userId ||
                    p.toLowerCase().trim() == pm.userId.toLowerCase().trim() ||
                    p.toLowerCase().trim() == pm.name.toLowerCase().trim()));

        if (isGroupWide) {
          final newParticipants = {
            ...expense.participants,
            newMember.userId,
          }.toList();
          return expense.copyWith(participants: newParticipants);
        }
        return expense;
      }).toList();

      final updatedStory = Story.create(
        storyId: currentStory.storyId,
        title: currentStory.title,
        description: currentStory.description,
        coverEmoji: currentStory.coverEmoji,
        currency: currentStory.currency,
        status: currentStory.status,
        splitMethod: currentStory.splitMethod,
        createdBy: currentStory.createdBy,
        createdAt: currentStory.createdAt,
        startDate: currentStory.startDate,
        endDate: currentStory.endDate,
        members: updatedMembers,
        expenses: updatedExpenses,
        existingSettlements: currentStory.settlements
            .where((s) => s.status == 'completed')
            .toList(),
        version: currentStory.version,
      );

      await updateStory(updatedStory);

      // Also add other story members to Friends list
      for (final m in updatedMembers) {
        if (m.userId != currentDeviceUserId &&
            m.name.toLowerCase() != effectiveUserName.toLowerCase()) {
          final existing = FriendsRepository.instance.friends
              .any((f) => f.name.toLowerCase() == m.name.toLowerCase());
          if (!existing) {
            FriendsRepository.instance
                .addFriend(Friend(name: m.name, phone: ''));
          }
        }
      }

      return updatedStory;
    } finally {
      _joiningStoryIds.remove(storyId);
    }
  }

  /// Adds a new story and persists it to Supabase.
  Future<void> addStory(Story story) async {
    final idx = _stories.indexWhere((s) => s.storyId == story.storyId);
    if (idx != -1) {
      _stories[idx] = story;
    } else {
      _stories.insert(0, story);
    }
    notifyListeners();
    await SupabaseService.saveStory(story);
  }

  /// Updates an existing story and persists it to Supabase.
  Future<void> updateStory(Story updatedStory) async {
    final index = _stories.indexWhere((s) => s.storyId == updatedStory.storyId);
    if (index != -1) {
      _stories[index] = updatedStory;
    } else {
      _stories.insert(0, updatedStory);
    }
    notifyListeners();
    await SupabaseService.saveStory(updatedStory);
  }

  /// Adds an expense to an existing story, automatically recalculating summary, balances, and settlements.
  Future<void> addExpenseToStory(String storyId, StoryExpense expense) async {
    final index = _stories.indexWhere((s) => s.storyId == storyId);
    if (index != -1) {
      final updated = _stories[index].addExpense(expense);
      _stories[index] = updated;
      notifyListeners();
      await SupabaseService.saveStory(updated);
    }
  }

  /// Marks a settlement inside a story as completed and updates settlement totals.
  Future<void> settlePayment(String storyId, String settlementId) async {
    final index = _stories.indexWhere((s) => s.storyId == storyId);
    if (index != -1) {
      final current = _stories[index];
      final updatedSettlements = current.settlements.map((s) {
        if (s.settlementId == settlementId) {
          return s.copyWith(status: 'completed');
        }
        return s;
      }).toList();

      final totalSettled = updatedSettlements.fold<double>(
        0.0,
        (sum, s) => s.status == 'completed' ? sum + s.amount : sum,
      );
      final pendingAmount = updatedSettlements.fold<double>(
        0.0,
        (sum, s) => s.status == 'pending' ? sum + s.amount : sum,
      );

      final updatedSummary = StorySummary(
        totalExpenses: current.summary.totalExpenses,
        totalSettled: totalSettled,
        pendingAmount: pendingAmount,
        memberCount: current.summary.memberCount,
        expenseCount: current.summary.expenseCount,
      );

      _stories[index] = Story(
        storyId: current.storyId,
        title: current.title,
        description: current.description,
        coverEmoji: current.coverEmoji,
        currency: current.currency,
        status: pendingAmount <= 0.01 ? 'settled' : current.status,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        startDate: current.startDate,
        endDate: current.endDate,
        members: current.members,
        summary: updatedSummary,
        expenses: current.expenses,
        memberBalances: current.memberBalances,
        settlements: updatedSettlements,
      );

      notifyListeners();
      await SupabaseService.saveStory(_stories[index]);
    }
  }

  /// Deletes a story by its identifier from Supabase and cleans up in-memory state.
  Future<void> deleteStory(String storyId) async {
    final storyIndex = _stories.indexWhere((s) => s.storyId == storyId);
    Story? storyToDelete;
    if (storyIndex != -1) {
      storyToDelete = _stories[storyIndex];
      _stories.removeAt(storyIndex);
    } else {
      storyToDelete = _stories.where((s) => s.storyId == storyId).firstOrNull;
      _stories.removeWhere((s) => s.storyId == storyId);
    }

    notifyListeners();
    await SupabaseService.deleteStory(storyId);

    if (storyToDelete != null) {
      final storyTitle = storyToDelete.title;
      final expenseIds =
          storyToDelete.expenses.map((e) => e.expenseId).toSet();
      ActivityRepository.instance.deleteActivitiesForStory(
        storyTitle,
        storyId: storyId,
        expenseIds: expenseIds,
      );
      await SupabaseService.deleteActivitiesForStory(
        storyTitle: storyTitle,
        storyId: storyId,
        expenseIds: expenseIds.toList(),
      );
    }
  }

  /// Updates all member instances of the current user with their chosen avatar.
  bool _applyAvatarToUserMembers(String avatar) {
    bool changed = false;
    final currentUserId = SupabaseService.currentUser?.id;
    final currentUserName = SupabaseService.userDisplayName?.toLowerCase() ??
        StorageService.instance.getStringSync('user_profile_name')?.toLowerCase() ??
        '';

    for (int i = 0; i < _stories.length; i++) {
      final story = _stories[i];
      final memberIndex = story.members.indexWhere((m) {
        if (currentUserId != null && m.userId == currentUserId) return true;
        final name = m.name.toLowerCase();
        if (currentUserName.isNotEmpty && name == currentUserName) return true;
        if (name == 'you') return true;
        return false;
      });

      if (memberIndex != -1) {
        final currentMember = story.members[memberIndex];
        if (currentMember.avatar != avatar) {
          final updatedMembers = List<StoryMember>.from(story.members);
          updatedMembers[memberIndex] = StoryMember(
            userId: currentMember.userId,
            name: currentMember.name,
            avatar: avatar,
            role: currentMember.role,
            joinedAt: currentMember.joinedAt,
          );
          _stories[i] = Story(
            storyId: story.storyId,
            title: story.title,
            description: story.description,
            coverEmoji: story.coverEmoji,
            currency: story.currency,
            status: story.status,
            createdBy: story.createdBy,
            createdAt: story.createdAt,
            startDate: story.startDate,
            endDate: story.endDate,
            members: updatedMembers,
            summary: story.summary,
            expenses: story.expenses,
            memberBalances: story.memberBalances,
            settlements: story.settlements,
          );
          changed = true;
        }
      }
    }
    return changed;
  }

  /// Updates the current user's avatar across all their stories and syncs to Supabase.
  Future<void> updateCurrentUserAvatar(String avatar) async {
    final changed = _applyAvatarToUserMembers(avatar);
    if (changed) {
      notifyListeners();
      for (final story in _stories) {
        SupabaseService.saveStory(story).ignore();
      }
    }
  }

  /// Clears all stories (for tests or resets).
  Future<void> clearAll() async {
    _stories.clear();
    ActivityRepository.instance.clearActivities();
    notifyListeners();
  }
}
