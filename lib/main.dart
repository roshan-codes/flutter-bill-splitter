import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';

export 'app/app.dart';
export 'features/friends/domain/models/friend.dart';
export 'features/friends/domain/models/group.dart';
export 'features/navigation/presentation/screens/main_screen.dart';
export 'features/expenses/presentation/screens/add_expense_screen.dart';
export 'features/expenses/presentation/screens/split_detail_screen.dart';

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
