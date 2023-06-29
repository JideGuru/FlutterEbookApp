import 'package:flutter_ebook_app/src/features/common/data/local/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => LocalStorage().getSharedPreferences()!,
);
