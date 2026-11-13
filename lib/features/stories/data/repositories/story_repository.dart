import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
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

  /// Initializes stories from offline persistent storage.
  /// If no stories exist yet, seeds the initial "Goa Trip" story.
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
      } else {
        // Seed default sample story provided in user requirements
        _stories.clear();
        _stories.add(Story.sampleGoaTrip());
        await _persist();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('StoryRepository init error: $e');
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
      notifyListeners();
      await _persist();
    }
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

  /// Deletes a story by its identifier.
  Future<void> deleteStory(String storyId) async {
    _stories.removeWhere((s) => s.storyId == storyId);
    notifyListeners();
    await _persist();
  }

  /// Clears all stories (for tests or resets).
  Future<void> clearAll() async {
    _stories.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final jsonStrings = _stories.map((s) => jsonEncode(s.toJson())).toList();
      await _storageService.setStringList(_storageKey, jsonStrings);
    } catch (e) {
      debugPrint('StoryRepository persist error: $e');
    }
  }
}
