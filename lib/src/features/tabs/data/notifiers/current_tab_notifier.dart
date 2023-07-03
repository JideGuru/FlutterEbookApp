import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentTabNotifier extends ValueNotifier<int> {
  CurrentTabNotifier() : super(0);

  bool get isHomeTab => value == 0;
  void changePage(int page) {
    value = page;
    notifyListeners();
  }
}

final currentTabNotifierProvider = Provider<CurrentTabNotifier>(
  (ref) => CurrentTabNotifier(),
);
