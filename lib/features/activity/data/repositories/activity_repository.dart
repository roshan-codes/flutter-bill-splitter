import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Repository responsible for providing access to and persisting recorded split activities via Supabase.
class ActivityRepository extends ChangeNotifier {
  static final ActivityRepository instance = ActivityRepository();

  ActivityRepository({StorageService? storageService});

  final List<SplitActivity> _activities = [];

  List<SplitActivity> get activities => List.unmodifiable(_activities);

  /// Initializes activities directly from Supabase Cloud Database.
  Future<void> init() async {
    try {
      final remote = await SupabaseService.fetchActivities();
      _activities.clear();
      _activities.addAll(remote);
      notifyListeners();
    } catch (e) {
      debugPrint('ActivityRepository init error: $e');
    }
  }

  /// Records a new split activity (inserted at top) and persists it directly to Supabase.
  void recordActivity(SplitActivity activity) {
    _activities.insert(0, activity);
    notifyListeners();
    SupabaseService.saveActivity(activity).ignore();
  }

  /// Deletes recorded activities associated with a given story by title, ID, or expense IDs.
  void deleteActivitiesForStory(String storyTitle,
      {String? storyId, Set<String>? expenseIds}) {
    _activities.removeWhere((a) {
      final matchesTitle =
          a.groupName.trim().toLowerCase() == storyTitle.trim().toLowerCase();
      final matchesStoryId = storyId != null &&
          (a.id.contains(storyId) || a.groupName.contains(storyId));
      final matchesExpenseId = expenseIds != null && expenseIds.contains(a.id);
      return matchesTitle || matchesStoryId || matchesExpenseId;
    });
    notifyListeners();
  }

  /// Clears all recorded activities (useful for test resets or user data reset).
  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }
}
