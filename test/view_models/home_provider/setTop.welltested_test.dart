import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeProvider homeProvider;

  setUp(() {
    homeProvider = HomeProvider();
  });

  test('Set top category feed', () {
    final categoryFeed = CategoryFeed();
    homeProvider.setTop(categoryFeed);
    expect(homeProvider.top, categoryFeed);
  });

  test('Notify listeners after setting top category feed', () {
    final categoryFeed = CategoryFeed();
    var listenerCalled = false;
    homeProvider.addListener(() {
      listenerCalled = true;
    });
    homeProvider.setTop(categoryFeed);
    expect(listenerCalled, true);
  });
}
