import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Repository responsible for storing, providing access to, and persisting recorded split activities.
class ActivityRepository extends ChangeNotifier {
  static final ActivityRepository instance = ActivityRepository();

  static const String _storageKey = 'split_activities_key';
  final StorageService _storageService;

  ActivityRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService.instance;

  final List<SplitActivity> _activities = [];

  List<SplitActivity> get activities => List.unmodifiable(_activities);

  /// Initializes and loads previously persisted activities from offline storage.
  Future<void> init() async {
    try {
      final jsonStrings = await _storageService.getStringList(_storageKey);
      if (jsonStrings != null && jsonStrings.isNotEmpty) {
        _activities.clear();
        for (final str in jsonStrings) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            _activities.add(SplitActivity.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing stored activity: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ActivityRepository init error: $e');
    }
  }

  /// Records a new split activity (inserted at the top so newest appears first)
  /// and automatically persists it to offline storage.
  void recordActivity(SplitActivity activity) {
    _activities.insert(0, activity);
    notifyListeners();
    _persist();
  }

  /// Clears all recorded activities (useful for test resets or user data reset).
  void clearActivities() {
    _activities.clear();
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final jsonStrings =
          _activities.map((a) => jsonEncode(a.toJson())).toList();
      await _storageService.setStringList(_storageKey, jsonStrings);
    } catch (e) {
      debugPrint('Error persisting activities: $e');
    }
  }
}
