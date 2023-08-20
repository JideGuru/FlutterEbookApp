import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/app.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage();
  await DatabaseConfig.init(StoreRef<dynamic, dynamic>.main());
  runApp(ProviderScope(child: MyApp()));
}
