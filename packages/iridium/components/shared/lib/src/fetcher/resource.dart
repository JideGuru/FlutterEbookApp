// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/src/fetcher/resource_exception.dart';
import 'package:universal_io/io.dart' hide Link;
import 'package:xml/xml.dart';

class ResourceTry<SuccessT> extends Try<SuccessT, ResourceException> {
  ResourceTry.success(SuccessT super.success) : super.success();

  ResourceTry.failure(ResourceException super.failure) : super.failure();

  @override
  ResourceTry<R> map<R>(R Function(SuccessT value) transform) {
    if (isSuccess) {
      return ResourceTry.success(transform(getOrThrow()));
    } else {
      return ResourceTry.failure(exceptionOrNull()!);
    }
  }

  /// Maps the result with the given [transform]
  ///
  /// If the [transform] throws an [Exception], it is wrapped in a failure with Resource.Exception.Other.
  ResourceTry<R> mapCatching<R>(R Function(SuccessT value) transform) {
    try {
      return ResourceTry.success((transform(getOrThrow())));
    } on Exception catch (e) {
      return ResourceTry.failure(ResourceException.wrap(e));
    } on OutOfMemoryError catch (e) {
      // We don't want to catch any Error, only OOM.
      return ResourceTry.failure(ResourceException.wrap(e));
    }
  }

  Future<ResourceTry<R>> mapWait<R>(
      Future<R> Function(SuccessT value) transform) async {
    try {
      return ResourceTry.success((await transform(getOrThrow())));
    } on Exception catch (e) {
      return ResourceTry.failure(ResourceException.wrap(e));
    } on OutOfMemoryError catch (e) {
      // We don't want to catch any Error, only OOM.
      return ResourceTry.failure(ResourceException.wrap(e));
    }
  }

  ResourceTry<R> flatMapResource<R>(
      ResourceTry<R> Function(SuccessT value) transform) {
    if (isSuccess) {
      return transform(getOrThrow());
    } else {
      return ResourceTry.failure(exceptionOrNull()!);
    }
  }

  ResourceTry<R> flatMapCatching<R>(
          ResourceTry<R> Function(SuccessT value) transform) =>
      mapCatching(transform).flatMapResource((value) => value);

  Future<ResourceTry<R>> flatMapWaitResource<R>(
          Future<ResourceTry<R>> Function(SuccessT value) transform) async =>
      (await mapWait(transform)).flatMapResource((value) => value);
}

/// Implements the transformation of a Resource. It can be used, for example, to decrypt,
/// deobfuscate, inject CSS or JavaScript, correct content – e.g. adding a missing dir="rtl" in an
/// HTML document, pre-process – e.g. before indexing a publication's content, etc.
///
/// If the transformation doesn't apply, simply return resource unchanged.
typedef ResourceTransformer = Resource Function(Resource resource);

/// Acts as a proxy to an actual resource by handling read access.
abstract class Resource {
  /// Direct file to this resource, when available.
  ///
  /// This is meant to be used as an optimization for consumers which can't work efficiently
  /// with streams. However, [file] is not guaranteed to be set, for example if the resource
  /// underwent transformations or is being read from an archive. Therefore, consumers should
  /// always fallback on regular stream reading, using [read] or [ResourceInputStream].
  File? get file => null;

  /// Returns the link from which the resource was retrieved.
  ///
  /// It might be modified by the [Resource] to include additional metadata, e.g. the
  /// `Content-Type` HTTP header in [Link.type].
  Future<Link> link();

  /// Returns data length from metadata if available, or calculated from reading the bytes otherwise.
  ///
  /// This value must be treated as a hint, as it might not reflect the actual bytes length. To get
  /// the real length, you need to read the whole resource.
  Future<ResourceTry<int>> length();

  /// Reads the bytes at the given range.
  ///
  /// When [range] is null, the whole content is returned. Out-of-range indexes are clamped to the
  /// available length automatically.
  Future<ResourceTry<ByteData>> read({IntRange? range});

  /// Reads the full content as a [String].
  ///
  /// If [charset] is null, then it is parsed from the `charset` parameter of link().type,
  /// or falls back on UTF-8.
  Future<ResourceTry<String>> readAsString({String? charset}) async {
    charset = charset ?? (await link()).mediaType.charset ?? Charsets.utf8;
    return read().then((st) => st.mapCatching((data) {
          Encoding encoding = Encoding.getByName(charset) ?? utf8;
          return encoding.decoder.convert(data.buffer.asUint8List());
        }));
  }

  /// Reads the full content as a JSON object.
  Future<ResourceTry<Map<String, dynamic>>> readAsJson() async =>
      (await readAsString(charset: Charsets.utf8))
          .mapCatching((it) => json.decode(it));

  /// Reads the full content as an XML document.
  Future<ResourceTry<XmlDocument>> readAsXml() => readAsString()
      .then((v) => v.mapCatching((input) => XmlDocument.parse(input)));

  /// Closes any opened file handles.
  ///
  /// If the Resource is already closed then invoking this method has no effect.
  Future<void> close();

  /// Executes the given block function on this resource and then closes it down correctly whether an exception is thrown or not.
  Future<R> use<R>(Future<R> Function(Resource resource) block) async {
    try {
      return block(this);
    } on Exception {
      rethrow;
    } finally {
      await close();
    }
  }

  /// Creates a cached resource wrapping this resource.
  Resource cached() {
    if (this is CachingResource) {
      return this;
    } else {
      return CachingResource(this);
    }
  }
}

/// Creates a Resource that will always return the given [error].
class FailureResource extends Resource {
  final Link _link;
  final ResourceException error;

  FailureResource(this._link, this.error);

  factory FailureResource.create(Link link, dynamic cause) =>
      FailureResource(link, ResourceException.other(cause));

  @override
  Future<Link> link() async => _link;

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) async =>
      ResourceTry.failure(error);

  @override
  Future<ResourceTry<int>> length() async => ResourceTry.failure(error);

  @override
  Future<void> close() async {}

  @override
  String toString() => "FailureResource($error)";
}

/// A base class for a [Resource] which acts as a proxy to another one.
///
/// Every function is delegating to the proxied resource, and subclasses should override some of them.
abstract class ProxyResource extends Resource {
  final Resource resource;

  ProxyResource(this.resource);

  @override
  Future<void> close() => resource.close();

  @override
  Future<ResourceTry<int>> length() => resource.length();

  @override
  Future<Link> link() => resource.link();

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) =>
      resource.read(range: range);

  @override
  String toString() => "ProxyResource($resource)";
}

/// Caches the members of [resource] on first access, to optimize subsequent accesses.
///
/// This can be useful when reading [resource] is expensive.
///
/// Warning: bytes are read and cached entirely the first time, even if only a [range] is requested.
/// So this is not appropriate for large resources.
class CachingResource extends Resource {
  final Resource resource;
  Link? _link;
  ResourceTry<int>? _length;
  ResourceTry<ByteData>? _bytes;

  CachingResource(this.resource);

  @override
  Future<Link> link() async => _link ??= await resource.link();

  @override
  Future<ResourceTry<int>> length() async {
    if (_length == null) {
      if (_bytes != null) {
        _length = _bytes!.map((it) => it.lengthInBytes);
      } else {
        _length = await resource.length();
      }
    }
    return _length!;
  }

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) async {
    _bytes ??= await resource.read();

    if (range == null) {
      return _bytes!;
    }

    return _bytes!.map((value) {
      IntRange range2 =
          IntRange(max(0, range.first), min(range.last, value.lengthInBytes));
      return value.buffer.asByteData(range2.first, range2.length);
    });
  }

  @override
  Future<void> close() => resource.close();

  @override
  String toString() => "CachingResource($resource)";
}

/// Transforms the bytes of [resource] on-the-fly.
///
/// Warning: The transformation runs on the full content of [resource], so it's not appropriate for
/// large resources which can't be held in memory. Also, wrapping a [TransformingResource] in a
/// [CachingResource] can be a good idea to cache the result of the transformation in case multiple
/// ranges will be read.
abstract class TransformingResource extends ProxyResource {
  TransformingResource(super.resource);

  Future<ResourceTry<ByteData>> transform(ResourceTry<ByteData> data);

  Future<ResourceTry<ByteData>> bytes() async =>
      transform(await resource.read());

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) async =>
      (await bytes()).map((value) {
        if (range == null) {
          return value;
        }

        IntRange range2 =
            IntRange(max(0, range.first), min(range.last, value.lengthInBytes));

        return value.buffer.asByteData(range2.first, range2.length);
      });

  @override
  Future<ResourceTry<int>> length() async =>
      (await bytes()).map((it) => it.lengthInBytes);
}

/// Wraps a [Resource] which will be created only when first accessing one of its members.
class LazyResource extends Resource {
  final Future<Resource> Function() factory;
  Resource? _resource;

  LazyResource(this.factory);

  Future<Resource> _getResource() async => _resource ??= await factory();

  @override
  Future<Link> link() => _getResource().then((r) => r.link());

  @override
  Future<ResourceTry<int>> length() => _getResource().then((r) => r.length());

  @override
  Future<ResourceTry<ByteData>> read({IntRange? range}) =>
      _getResource().then((r) => r.read(range: range));

  @override
  Future<void> close() async {
    if (_resource == null) {
      await _resource?.close();
    }
  }

  @override
  String toString() {
    if (_resource != null) {
      return "LazyResource($_resource)";
    } else {
      return "LazyResource(...)";
    }
  }
}
