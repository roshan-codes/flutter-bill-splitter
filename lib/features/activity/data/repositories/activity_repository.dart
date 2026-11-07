import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Repository responsible for storing and providing access to recorded split activities.
class ActivityRepository extends ChangeNotifier {
  static final ActivityRepository instance = ActivityRepository();

  final List<SplitActivity> _activities = [];

  List<SplitActivity> get activities => List.unmodifiable(_activities);

  /// Records a new split activity (inserted at the top so newest appears first).
  void recordActivity(SplitActivity activity) {
    _activities.insert(0, activity);
    notifyListeners();
  }

  /// Clears all recorded activities (useful for test resets).
  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }
}

