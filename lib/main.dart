import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'configs/env.dart';
import 'database/app_database.dart';
import 'database/food_seed.dart';
import 'repositories/drift_meal_repository.dart';
import 'repositories/secure_session_storage.dart';
import 'services/meal_photo_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  final photos = MealPhotoStorage(Directory('${documents.path}/meal_photos'));
  final database = AppDatabase.open(
    foodSeed: () => loadFoodSeed(rootBundle),
    clearUserFiles: photos.deleteAll,
  );
  // Antes do runApp: rodando junto com o app, a limpeza poderia apagar a
  // foto de uma refeição salva nesses primeiros instantes.
  try {
    await DriftMealRepository(database, photos: photos).prunePhotos();
  } on Object catch (e, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: e, stack: stack, library: 'meal photos'),
    );
  }
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
  runApp(OzApp(database: database, photos: photos, supabase: supabase));
}
