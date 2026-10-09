import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'database/food_seed.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.open(foodSeed: () => loadFoodSeed(rootBundle));
  runApp(OzApp(database: database));
}
