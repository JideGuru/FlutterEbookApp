// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/utils/ref.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:test/test.dart';

class FooService extends PublicationService {
  @override
  Type get serviceType => FooService;
}

class FooServiceA extends FooService {}

class FooServiceB extends FooService {}

class FooServiceC extends FooService {
  final FooService? wrapped;

  FooServiceC(this.wrapped);
}

class BarService extends PublicationService {
  @override
  Type get serviceType => BarService;
}

class BarServiceA extends BarService {}

var context = PublicationServiceContext(
    Ref<Publication>(),
    Manifest(
        metadata: Metadata(localizedTitle: LocalizedString.fromStrings({}))),
    EmptyFetcher());

extension PublicationServiceFind on List<PublicationService> {
  T? find<T>() => whereType<T>().firstOrNull;
}

void main() {
  test("testBuild", () {
    var services = ServicesBuilder.create(cover: null).also((it) {
      it.set<FooService>((c) => FooServiceA());
      it.set<BarService>((c) => BarServiceA());
    }).build(context);

    expect(services.find<FooServiceA>(), isNotNull);
    expect(services.find<BarServiceA>(), isNotNull);
  });

  test("testBuildEmpty", () {
    var builder = ServicesBuilder.create(cover: null);
    var services = builder.build(context);
    expect(1, services.length);
    expect(services.find<DefaultLocatorService>(), isNotNull);
  });

  test("testSetOverwrite", () {
    var services = ServicesBuilder.create(cover: null).also((it) {
      it.set<FooService>((c) => FooServiceA());
      it.set<FooService>((c) => FooServiceB());
    }).build(context);

    expect(services.find<FooServiceB>(), isNotNull);
    expect(services.find<FooServiceA>(), isNull);
  });

  test("testRemoveExisting", () {
    var services = ServicesBuilder.create(cover: null).also((it) {
      it.set<FooService>((c) => FooServiceA());
      it.set<BarService>((c) => BarServiceA());
      it.remove(FooService);
    }).build(context);

    expect(services.find<BarServiceA>(), isNotNull);
    expect(services.find<FooServiceA>(), isNull);
  });

  test("testRemoveUnknown", () {
    var services = ServicesBuilder.create(cover: null).also((it) {
      it.set<FooService>((c) => FooServiceA());
      it.remove(BarService);
    }).build(context);

    expect(services.find<FooServiceA>(), isNotNull);
    expect(services.find<BarService>(), isNull);
  });

  test("testDecorate", () {
    var services = ServicesBuilder.create(cover: null).also((it) {
      it.set<FooService>((c) => FooServiceB());
      it.set<BarService>((c) => BarServiceA());
      it.decorate(
          FooService,
          (oldFactory) => (context) =>
              FooServiceC(oldFactory?.let((it) => it(context) as FooService)));
    }).build(context);

    expect(services.find<FooServiceC>(), isNotNull);
    expect(services.find<FooServiceC>()?.wrapped, isA<FooServiceB>());
    expect(services.find<BarServiceA>(), isNotNull);
  });
}
