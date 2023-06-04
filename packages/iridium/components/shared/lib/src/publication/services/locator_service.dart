// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/ref.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/publication.dart';

/// Locates the destination of various sources (e.g. locators, progression, etc.) in the
/// publication.
///
/// This service can be used to implement a variety of features, such as:
///   - Jumping to a given position or total progression, by converting it first to a [Locator].
///   - Converting a [Locator] which was created from an alternate manifest with a different reading
///     order. For example, when downloading a streamed manifest or offloading a package.
abstract class LocatorService extends PublicationService {
  /// Locates the target of the given [locator].
  Future<Locator?> locate(Locator locator);

  /// Locates the target at the given [totalProgression] relative to the whole publication.
  Future<Locator?> locateProgression(double totalProgression);

  @override
  void close() {}

  @override
  Type get serviceType => LocatorService;
}

class DefaultLocatorService extends LocatorService {
  final List<Link> readingOrder;
  final Future<List<List<Locator>>> Function() positionsByReadingOrder;

  DefaultLocatorService(this.readingOrder, this.positionsByReadingOrder);

  factory DefaultLocatorService.create(
          List<Link> readingOrder, Ref<Publication> publication) =>
      DefaultLocatorService(readingOrder,
          () => publication()?.positionsByReadingOrder() ?? Future.value([]));

  @override
  Future<Locator?> locate(Locator locator) async =>
      locator.takeIf((it) => readingOrder.firstWithHref(locator.href) != null);

  @override
  Future<Locator?> locateProgression(double totalProgression) async {
    if (totalProgression < 0.0 || 1.0 < totalProgression) {
      Fimber.e(
          "Progression must be between 0.0 and 1.0, received $totalProgression)");
      return null;
    }
    List<List<Locator>> positions = await positionsByReadingOrder();
    _Position? position = _findClosestTo(totalProgression, positions);
    if (position == null) {
      return null;
    }
    Locator locator = position.locator;
    return locator.copyWithLocations(
      progression: _resourceProgressionFor(totalProgression, positions,
              readingOrderIndex: position.readingOrderIndex) ??
          locator.locations.progression,
      totalProgression: totalProgression,
    );
  }

  /// Finds the [Locator] in the given [positions] which is the closest to the given
  /// [totalProgression], without exceeding it.
  _Position? _findClosestTo(
      double totalProgression, List<List<Locator>> positions) {
    _Match<Locator>? lastPosition = _findLast(positions);
    if (lastPosition == null) {
      return null;
    }
    double? lastProgression = lastPosition.item.locations.totalProgression;
    if (lastProgression != null && totalProgression >= lastProgression) {
      return _Position(lastPosition.x, lastPosition.item);
    }

    bool inBetween(Locator first, Locator second) {
      double? prog1 = first.locations.totalProgression;
      if (prog1 == null) {
        return false;
      }
      double? prog2 = second.locations.totalProgression;
      if (prog2 == null) {
        return false;
      }
      return prog1 <= totalProgression && totalProgression < prog2;
    }

    _Match<Locator>? position = _findFirstByPair(positions, inBetween);
    if (position == null) {
      return null;
    }
    return _Position(position.x, position.item);
  }

  /// Computes the progression relative to a reading order resource at the given index, from its
  /// [totalProgression] relative to the whole publication.
  double? _resourceProgressionFor(
      double totalProgression, List<List<Locator>> positions,
      {required int readingOrderIndex}) {
    double? startProgression =
        positions[readingOrderIndex].firstOrNull?.locations.totalProgression;
    if (startProgression == null) {
      return null;
    }
    double endProgression = positions
            .elementAtOrNull(readingOrderIndex + 1)
            ?.firstOrNull
            ?.locations
            .totalProgression ??
        1.0;
    if (totalProgression <= startProgression) {
      return 0.0;
    }
    if (totalProgression >= endProgression) {
      return 1.0;
    }
    return (totalProgression - startProgression) /
        (endProgression - startProgression);
  }

  /// Finds the first item matching the given condition when paired with its successor.
  _Match<T>? _findFirstByPair<T>(
      List<List<T>> items, bool Function(T, T) condition) {
    _Match<T>? previous;
    for (int x = 0; x < items.length; x++) {
      List<T> section = items[x];
      for (int y = 0; y < section.length; y++) {
        T item = section[y];
        if (previous != null) {
          if (condition(previous.item, item)) {
            return previous;
          }
        }
        previous = _Match(x: x, y: y, item: item);
      }
    }
    return null;
  }

  /// Finds the last item in the last non-empty list of [items].
  _Match<T>? _findLast<T>(List<List<T>> items) {
    _Match<T>? last;

    for (int x = 0; x < items.length; x++) {
      List<T> section = items[x];
      for (int y = 0; y < section.length; y++) {
        T item = section[y];
        last = _Match(x: x, y: y, item: item);
      }
    }

    return last;
  }
}

class _Position {
  final int readingOrderIndex;
  final Locator locator;

  _Position(this.readingOrderIndex, this.locator);

  @override
  String toString() =>
      '_Position{readingOrderIndex: $readingOrderIndex, locator: $locator}';
}

/// Holds an item and its position in a two-dimensional array.
class _Match<T> {
  final int x;
  final int y;
  final T item;

  _Match({required this.x, required this.y, required this.item});

  @override
  String toString() => '_Match{x: $x, y: $y, item: $item}';
}

extension PublicationLocatorExtension on Publication {
  /// Locates the target of the given [locator].
  Future<Locator?> locate(Locator locator) async =>
      await findService<LocatorService>()?.locate(locator);

  /// Locates the target at the given [progression] relative to the whole publication.
  Future<Locator?> locateProgression(double totalProgression) async =>
      await findService<LocatorService>()?.locateProgression(totalProgression);
}

extension ServicesBuilderLocatorExtension on ServicesBuilder {
  ServiceFactory? getLocatorServiceFactory() => of<LocatorService>();

  set locatorServiceFactory(ServiceFactory serviceFactory) =>
      set<LocatorService>(serviceFactory);
}
