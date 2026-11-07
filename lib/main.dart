import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';

export 'app/app.dart';
export 'features/friends/domain/models/friend.dart';
export 'features/friends/domain/models/group.dart';
export 'features/navigation/presentation/screens/main_screen.dart';
export 'features/expenses/presentation/screens/add_expense_screen.dart';
export 'features/expenses/presentation/screens/split_detail_screen.dart';
export 'features/expenses/presentation/screens/split_summary_screen.dart';
export 'features/expenses/domain/models/settlement_transaction.dart';
export 'features/expenses/domain/services/expense_calculator.dart';
export 'features/activity/domain/models/split_activity.dart';
export 'features/activity/data/repositories/activity_repository.dart';
export 'features/activity/presentation/screens/activity_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}
