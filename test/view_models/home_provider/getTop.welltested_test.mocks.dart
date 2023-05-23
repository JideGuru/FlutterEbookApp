// Mocks generated by Mockito 5.4.0 from annotations
// in flutter_ebook_app/test/view_models/home_provider/getTop.welltested_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:dio/dio.dart' as _i2;
import 'package:flutter_ebook_app/models/category.dart' as _i3;
import 'package:flutter_ebook_app/util/api.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDio_0 extends _i1.SmartFake implements _i2.Dio {
  _FakeDio_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCategoryFeed_1 extends _i1.SmartFake implements _i3.CategoryFeed {
  _FakeCategoryFeed_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Api].
///
/// See the documentation for Mockito's code generation for more information.
class MockApi extends _i1.Mock implements _i4.Api {
  MockApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Dio get dio => (super.noSuchMethod(
        Invocation.getter(#dio),
        returnValue: _FakeDio_0(
          this,
          Invocation.getter(#dio),
        ),
      ) as _i2.Dio);
  @override
  set dio(_i2.Dio? _dio) => super.noSuchMethod(
        Invocation.setter(
          #dio,
          _dio,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i5.Future<_i3.CategoryFeed> getCategory(String? url) => (super.noSuchMethod(
        Invocation.method(
          #getCategory,
          [url],
        ),
        returnValue: _i5.Future<_i3.CategoryFeed>.value(_FakeCategoryFeed_1(
          this,
          Invocation.method(
            #getCategory,
            [url],
          ),
        )),
      ) as _i5.Future<_i3.CategoryFeed>);
}

/// A class which mocks [CategoryFeed].
///
/// See the documentation for Mockito's code generation for more information.
class MockCategoryFeed extends _i1.Mock implements _i3.CategoryFeed {
  MockCategoryFeed() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set version(String? _version) => super.noSuchMethod(
        Invocation.setter(
          #version,
          _version,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set encoding(String? _encoding) => super.noSuchMethod(
        Invocation.setter(
          #encoding,
          _encoding,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set feed(_i3.Feed? _feed) => super.noSuchMethod(
        Invocation.setter(
          #feed,
          _feed,
        ),
        returnValueForMissingStub: null,
      );
  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}
