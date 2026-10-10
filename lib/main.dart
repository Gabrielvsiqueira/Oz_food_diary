import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'configs/env.dart';
import 'database/app_database.dart';
import 'database/food_seed.dart';
import 'repositories/secure_session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.open(foodSeed: () => loadFoodSeed(rootBundle));
  SupabaseClient? supabase;
  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
      ),
    );
    supabase = Supabase.instance.client;
  }
  runApp(OzApp(database: database, supabase: supabase));
}
