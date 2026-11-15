import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Repository managing persistent storage of group expense stories adhering to the standard story JSON schema.
class StoryRepository extends ChangeNotifier {
  static final StoryRepository instance = StoryRepository();

  static const String _storageKey = 'saved_stories_key';
  final StorageService _storageService;

  StoryRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService.instance;

  final List<Story> _stories = [];

  List<Story> get stories => List.unmodifiable(_stories);

  /// Initializes stories from offline persistent storage and syncs with Supabase.
  Future<void> init() async {
    try {
      final jsonStrings = await _storageService.getStringList(_storageKey);
      if (jsonStrings != null && jsonStrings.isNotEmpty) {
        _stories.clear();
        for (final str in jsonStrings) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            _stories.add(Story.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing stored story: $e');
          }
        }
      }
      final currentAvatar = SupabaseService.resolvedUserAvatar;
      if (currentAvatar != null) {
        _applyAvatarToUserMembers(currentAvatar);
      }
      notifyListeners();

      // Sync stories with Supabase Cloud
      _syncFromSupabase().ignore();
    } catch (e) {
      debugPrint('StoryRepository init error: $e');
    }
  }

  Future<void> _syncFromSupabase() async {
    try {
      final remote = await SupabaseService.fetchStories();
      if (remote.isNotEmpty) {
        bool changed = false;
        for (final r in remote) {
          final idx = _stories.indexWhere((s) => s.storyId == r.storyId);
          if (idx == -1) {
            _stories.add(r);
            changed = true;
          }
        }
        final currentAvatar = SupabaseService.resolvedUserAvatar;
        if (currentAvatar != null) {
          if (_applyAvatarToUserMembers(currentAvatar)) {
            changed = true;
          }
        }
        if (changed) {
          notifyListeners();
          final jsonStrings =
              _stories.map((s) => jsonEncode(s.toJson())).toList();
          await _storageService.setStringList(_storageKey, jsonStrings);
        }
      }
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

      final userId = SupabaseService.currentUser?.id ?? 'user_guest';
      final userName = SupabaseService.userDisplayName ??
          await StorageService.instance.getString('user_profile_name') ??
          'Friend';
      final userAvatar = SupabaseService.resolvedUserAvatar;

      final cleanUser = userName.toLowerCase().trim();
      final uFirst = cleanUser.split(' ').first;

      // Check if user is already a member (or matches an existing manual member slot)
      final existingIndex = story.members.indexWhere((m) {
        final cleanM = m.name.toLowerCase().trim();
        final mId = m.userId.trim();

        // 1. Authenticated user ID matches
        if (userId != 'user_guest' &&
            userId.isNotEmpty &&
            mId.isNotEmpty &&
            mId == userId) {
          return true;
        }

        // 2. Exact normalized name matches
        if (cleanUser.isNotEmpty && cleanM == cleanUser) return true;

        // 3. 'You' matches ONLY if current user is the story creator
        if (cleanM == 'you' &&
            (story!.createdBy == userId ||
                story.createdBy == 'user_guest' ||
                story.createdBy.isEmpty)) {
          return true;
        }

        // 4. First name matches full name (e.g. "Roshan" and "Roshan Badwaik")
        final mFirst = cleanM.split(' ').first;
        if (mFirst == uFirst && mFirst.length > 2) return true;

        // 5. Manual generated ID matches: user_roshan matches Roshan
        if (mId == 'user_${cleanUser.replaceAll(' ', '_')}') return true;

        return false;
      });

      if (existingIndex != -1) {
        // User is already a member or has a pre-existing manual member slot.
        // Claim and upgrade their existing slot with real authenticated userId and avatar.
        final existing = story.members[existingIndex];
        final updatedMember = StoryMember(
          userId: (userId != 'user_guest' && userId.isNotEmpty)
              ? userId
              : (existing.userId.isNotEmpty ? existing.userId : userId),
          name: (existing.name.toLowerCase().trim() == 'you' ||
                  cleanUser.length > existing.name.length)
              ? userName
              : existing.name,
          avatar: userAvatar ?? existing.avatar,
          role: existing.role,
          joinedAt: existing.joinedAt.isNotEmpty
              ? existing.joinedAt
              : DateTime.now().toIso8601String(),
        );

        final updatedMembers = List<StoryMember>.from(story.members);
        updatedMembers[existingIndex] = updatedMember;

        final updatedBalances = story.memberBalances.map((b) {
          final bClean = b.name.toLowerCase().trim();
          final exClean = existing.name.toLowerCase().trim();
          if (b.userId == existing.userId ||
              bClean == exClean ||
              bClean == cleanUser ||
              (b.userId.isNotEmpty && b.userId == userId)) {
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
        await SupabaseService.saveStory(updatedStory);
        return updatedStory;
      }

      // Truly new member joining
      final now = DateTime.now();
      final newMember = StoryMember(
        userId: userId,
        name: userName,
        avatar: userAvatar,
        role: 'member',
        joinedAt: now.toIso8601String(),
      );

      final updatedMembers =
          Story.deduplicateMembers([...story.members, newMember]);
      final updatedBalances = Story.deduplicateBalances([
        ...story.memberBalances,
        StoryMemberBalance(
          userId: userId,
          name: userName,
          totalPaid: 0.0,
          totalShare: 0.0,
          netBalance: 0.0,
          status: 'settled',
        ),
      ]);

      final updatedSummary = StorySummary(
        totalExpenses: story.summary.totalExpenses,
        totalSettled: story.summary.totalSettled,
        pendingAmount: story.summary.pendingAmount,
        memberCount: updatedMembers.length,
        expenseCount: story.summary.expenseCount,
      );

      final updatedStory = Story(
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
        expenses: story.expenses,
        memberBalances: updatedBalances,
        settlements: story.settlements,
        summary: updatedSummary,
      );

      await updateStory(updatedStory);
      await SupabaseService.saveStory(updatedStory);

      // Also add other story members to Friends list
      for (final m in updatedMembers) {
        if (m.userId != userId &&
            m.name.toLowerCase() != userName.toLowerCase()) {
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

  /// Adds a new story and persists it.
  Future<void> addStory(Story story) async {
    _stories.insert(0, story);
    notifyListeners();
    await _persist();
  }

  /// Updates an existing story and persists it.
  Future<void> updateStory(Story updatedStory) async {
    final index = _stories.indexWhere((s) => s.storyId == updatedStory.storyId);
    if (index != -1) {
      _stories[index] = updatedStory;
    } else {
      _stories.insert(0, updatedStory);
    }
    notifyListeners();
    await _persist();
  }

  /// Adds an expense to an existing story, automatically recalculating summary, balances, and settlements.
  Future<void> addExpenseToStory(String storyId, StoryExpense expense) async {
    final index = _stories.indexWhere((s) => s.storyId == storyId);
    if (index != -1) {
      final updated = _stories[index].addExpense(expense);
      _stories[index] = updated;
      notifyListeners();
      await _persist();
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
      await _persist();
    }
  }

  /// Deletes a story by its identifier and cleans up associated activities and expenses.
  Future<void> deleteStory(String storyId) async {
    final storyIndex = _stories.indexWhere((s) => s.storyId == storyId);
    String? storyTitle;
    if (storyIndex != -1) {
      storyTitle = _stories[storyIndex].title;
      _stories.removeAt(storyIndex);
    } else {
      _stories.removeWhere((s) => s.storyId == storyId);
    }

    if (storyTitle != null && storyTitle.isNotEmpty) {
      ActivityRepository.instance
          .deleteActivitiesForStory(storyTitle, storyId: storyId);
    }

    // If no stories remain, clean up remaining orphan activities
    if (_stories.isEmpty) {
      ActivityRepository.instance.clearActivities();
    }

    notifyListeners();
    await _persist();
    SupabaseService.deleteStory(storyId).ignore();
  }

  /// Updates the current user's avatar across all their stories.
  Future<void> updateCurrentUserAvatar(String avatar) async {
    final changed = _applyAvatarToUserMembers(avatar);
    if (changed) {
      notifyListeners();
      await _persist();
    }
  }

  bool _isMemberCurrentUser(StoryMember m) {
    final currentUserId = SupabaseService.currentUser?.id;
    final currentUserName = SupabaseService.userDisplayName ??
        _storageService.getStringSync('user_profile_name') ??
        'Roshan';

    if (currentUserId != null &&
        m.userId.isNotEmpty &&
        m.userId == currentUserId) {
      return true;
    }
    final cleanM = m.name.toLowerCase().trim();
    final cleanUser = currentUserName.toLowerCase().trim();
    if (cleanM == 'you' || cleanM == cleanUser) return true;
    if (cleanUser.isNotEmpty &&
        (cleanM.contains(cleanUser) || cleanUser.contains(cleanM))) {
      return true;
    }
    if (cleanM == 'roshan' || cleanM == 'roshan badwaik') return true;
    if (m.role == 'creator') return true;
    return false;
  }

  bool _applyAvatarToUserMembers(String avatar) {
    bool changed = false;
    for (int i = 0; i < _stories.length; i++) {
      final story = _stories[i];
      final memberIndex = story.members.indexWhere(_isMemberCurrentUser);
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

  /// Clears all stories (for tests or resets).
  Future<void> clearAll() async {
    _stories.clear();
    ActivityRepository.instance.clearActivities();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final jsonStrings = _stories.map((s) => jsonEncode(s.toJson())).toList();
      await _storageService.setStringList(_storageKey, jsonStrings);

      // Asynchronously sync stories to Supabase Cloud
      for (final story in _stories) {
        SupabaseService.saveStory(story).ignore();
      }
    } catch (e) {
      debugPrint('StoryRepository persist error: $e');
    }
  }
}
