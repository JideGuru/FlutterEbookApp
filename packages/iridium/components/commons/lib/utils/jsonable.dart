// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/take.dart';

mixin JSONable {
  /// Serializes the object to its JSON representation.
  Map<String, dynamic> toJson();
}

extension IterableJSONableExtension on Iterable<JSONable> {
  /// Serializes a list of [JSONable] into a [List<Map<String, dynamic>>].
  List<Map<String, dynamic>> toJson() =>
      this.map((it) => it.toJson()).whereNotNull().toList();
}

extension MapExtension on Map<String, dynamic>? {
  static const String _null = "null";

  dynamic _wrapJSON(dynamic value) {
    if (value is JSONable) {
      return value.toJson().takeIf((it) => it.isNotEmpty);
    } else if (value is Map) {
      return (value).takeIf((it) => it.isNotEmpty)?.map(
          (key, value) => MapEntry<dynamic, dynamic>(key, _wrapJSON(value)));
    } else if (value is List) {
      return (value)
          .takeIf((it) => it.isNotEmpty)
          ?.mapNotNull(_wrapJSON)
          .toList();
    }
    return value;
  }

  String? __toString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value != null) {
      return value.toString();
    }
    return null;
  }

  bool? _toBoolean(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toBooleanOrNull();
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  int? _toInteger(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Returns true if this object has no mapping for {@code name} or if it has
  /// a mapping whose value is {@link #NULL}.
  bool isNull(String name) {
    dynamic value = opt(name);
    return value == null || value == _null;
  }

  /// Returns the value mapped by {@code name}, or null if no such mapping
  /// exists.
  dynamic opt(String name) => (this != null) ? this![name] : null;

  void put(String name, dynamic object) {
    if (this != null) {
      this![name] = object;
    }
  }

  void putOpt(String? name, Object? value) {
    if (name == null || value == null) {
      return;
    }
    put(name, value);
  }

  /// Maps [name] to [jsonObject], clobbering any existing name/value mapping with the same name. If
  /// the [Map] is empty, any existing mapping for [name] is removed.
  void putObjectIfNotEmpty(String name, Map<String, dynamic>? jsonObject) {
    if (jsonObject == null || jsonObject.isEmpty) {
      this?.remove(name);
      return;
    }
    put(name, jsonObject);
  }

  /// Maps [name] to [jsonable] after converting it to a [Map], clobbering any existing
  /// name/value mapping with the same name. If the [Map] argument is empty, any existing mapping
  /// for [name] is removed.
  void putJSONableIfNotEmpty(String name, JSONable? jsonable) {
    Map<String, dynamic>? json = jsonable?.toJson();
    if (json == null || json.isEmpty) {
      this?.remove(name);
      return;
    }
    put(name, json);
  }

  /// Maps [name] to [collection] after wrapping it in a [List], clobbering any existing
  /// name/value mapping with the same name. If the collection is empty, any existing mapping
  /// for [name] is removed.
  /// If the objects in [collection] are [JSONable], then they are converted to [Map] first.
  void putIterableIfNotEmpty(String name, Iterable<dynamic>? collection) {
    List list = collection?.whereNotNull().mapNotNull(_wrapJSON).toList() ?? [];
    if (list.isEmpty) {
      this?.remove(name);
      return;
    }
    put(name, list);
  }

  /// Maps [name] to [map] after wrapping it in a [Map], clobbering any existing name/value
  /// mapping with the same name. If the map is empty, any existing mapping for [name] is removed.
  /// If the objects in [map] are [JSONable], then they are converted to [Map] first.
  void putMapIfNotEmpty(String name, Map<String, dynamic> map) {
    Map<String, dynamic> map2 =
        map.map((key, value) => MapEntry(key, _wrapJSON(value)));
    if (map2.isEmpty) {
      this?.remove(name);
      return;
    }
    put(name, map2);
  }

  /// Returns the value mapped by [name] if it exists and is a positive integer or can be coerced to a
  /// positive integer, or [fallback] otherwise.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  int? optPositiveInt(String name, {int fallback = -1, bool remove = false}) {
    int i = optInt(name, fallback: fallback);
    int? value = (i >= 0) ? i : null;
    if (remove) {
      this?.remove(name);
    }
    return value;
  }

  /// Returns the value mapped by [name] if it exists and is a positive double or can be coerced to a
  /// positive double, or [fallback] otherwise.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  double? optPositiveDouble(String name,
      {double fallback = -1.0, bool remove = false}) {
    double d = optDouble(name, fallback: fallback);
    double? value = (d >= 0) ? d : null;
    if (remove) {
      this?.remove(name);
    }
    return value;
  }

  /// Returns the value mapped by [name] if it exists, coercing it if necessary, or `null` if no such
  /// mapping exists.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  String? optNullableString(String name, {bool remove = false}) {
// optString() returns "null" if the key exists but contains the `null` value.
// https://stackoverflow.com/questions/18226288/json-jsonobject-optstring-returns-string-null
    if (isNull(name)) {
      return null;
    }
    String s = optString(name);
    String? value = (s != "") ? s : null;
    if (remove) {
      this?.remove(name);
    }
    return value;
  }

  /// Returns the value mapped by {@code name} if it exists, coercing it if
  /// necessary, or {@code fallback} if no such mapping exists.
  String optString(String name, {String fallback = ""}) {
    dynamic object = opt(name);
    return __toString(object) ?? fallback;
  }

  /// Returns the value mapped by {@code name} if it exists and is a boolean or
  /// can be coerced to a boolean, or {@code fallback} otherwise.
  bool optBoolean(String name, {bool fallback = false}) {
    dynamic object = opt(name);
    return _toBoolean(object) ?? fallback;
  }

  /// Returns the value mapped by {@code name} if it exists and is an int or
  /// can be coerced to an int, or {@code fallback} otherwise.
  int optInt(String name, {int fallback = 0}) {
    dynamic object = opt(name);
    return _toInteger(object) ?? fallback;
  }

  /// Returns the value mapped by {@code name} if it exists and is a double or
  /// can be coerced to a double, or {@code fallback} otherwise.
  double optDouble(String name, {double fallback = double.nan}) {
    dynamic object = opt(name);
    return _toDouble(object) ?? fallback;
  }

  /// Returns the value mapped by {@code name} if it exists and is a {@code
  /// Map}, or null otherwise.
  Map<String, dynamic>? optJSONObject(String name) {
    dynamic object = opt(name);
    return object is Map<String, dynamic> ? object : null;
  }

  /// Returns the value mapped by {@code name} if it exists and is a {@code
  /// JSONArray}, or null otherwise.
  List<dynamic>? optJSONArray(String name) {
    dynamic object = opt(name);
    return object is Iterable ? object.toList() : null;
  }

  /// Returns the value mapped by [name] if it exists, coercing it if necessary, or `null` if no such
  /// mapping exists.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  bool? optNullableBoolean(String name, {bool remove = false}) {
    if (this?.containsKey(name) == false) {
      return null;
    }
    bool boolean = optBoolean(name);
    if (remove) {
      this?.remove(name);
    }
    return boolean;
  }

  /// Returns the value mapped by [name] if it exists, coercing it if necessary, or `null` if no such
  /// mapping exists.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  int? optNullableInt(String name, {bool remove = false}) {
    if (this?.containsKey(name) == false) {
      return null;
    }
    int value = optInt(name);
    if (remove) {
      this?.remove(name);
    }
    return value;
  }

  /// Returns the value mapped by [name] if it exists, coercing it if necessary, or `null` if no such
  /// mapping exists.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  double? optNullableDouble(String name, {bool remove = false}) {
    if (this?.containsKey(name) == false) {
      return null;
    }
    double value = optDouble(name);
    if (remove) {
      this?.remove(name);
    }
    return value;
  }

  /// Returns a list containing the results of applying the given transform function to each element
  /// in the original [Map].
  /// If the tranform returns `null`, it is not included in the output list.
  List<T> mapNotNull<T>(T Function(String, dynamic) transform) {
    List<T> result = [];
    if (this != null) {
      for (String key in this!.keys) {
        T transformedValue = transform(key, this![key]);
        if (transformedValue != null) {
          result.add(transformedValue);
        }
      }
    }
    return result;
  }

  /// Returns the value mapped by [name] if it exists and is either a [List] of [String] or a
  /// single [String] value, or an empty list otherwise.
  /// If [remove] is true, then the mapping will be removed from the [Map].
  ///
  /// E.g. ["a", "b"] or "a"
  List<String> optStringsFromArrayOrSingle(String name, {bool remove = false}) {
    dynamic value = (remove) ? this?.remove(name) : opt(name);
    if (value is Map) {
      return (value).values.whereType<String>().toList();
    } else if (value is List) {
      return value.whereType<String>().toList();
    } else if (value is String) {
      return [value];
    } else {
      return [];
    }
  }
}

extension ListExtension on List<dynamic>? {
  /// Parses a JSONArray of JSONObject into a [List] of models using the given [transform].
  List<T> parseObjects<T>(T? Function(dynamic) transform) {
    if (this == null || this!.isEmpty) {
      return [];
    }
    List<T> models = [];
    for (dynamic element in this!) {
      T? model = transform(element);
      if (model != null) {
        models.add(model);
      }
    }
    return models;
  }
}
