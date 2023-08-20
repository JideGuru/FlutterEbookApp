import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

final storeRefProvider = Provider<StoreRef<String, Map<String, dynamic>>>(
  (ref) => StoreRef<String, Map<String, dynamic>>.main(),
);

final downloadsDatabaseProvider = Provider<Database>(
  (ref) => DatabaseConfig.getDatabaseInstance(
    DatabaseConfig.downloadsDatabaseName,
  ),
);

final favoritesDatabaseProvider = Provider<Database>(
  (ref) => DatabaseConfig.getDatabaseInstance(
    DatabaseConfig.favoritesDatabaseName,
  ),
);
