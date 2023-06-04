// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:universal_io/io.dart';

typedef LcpWrapperCreateContext = LcpDrmContext Function(
    Pointer<Utf8> jsonLicense,
    Pointer<Utf8> hashedPassphrase,
    Pointer<Utf8> pemCrl);

late LcpWrapperCreateContext fLcpWrapperCreateContext;

typedef LcpWrapperFindOneValidPassphraseNative = Pointer<Utf8> Function(
    Pointer<Utf8> jsonLicense, Int64 hashedPassphrases);

typedef LcpWrapperFindOneValidPassphrase = Pointer<Utf8> Function(
    Pointer<Utf8> jsonLicense, int hashedPassphrasesPtr);

late LcpWrapperFindOneValidPassphrase fLcpWrapperFindOneValidPassphrase;

typedef LcpWrapperNativeDecrypt = Uint8Array Function(
    Pointer<LcpDrmContext> context, Pointer<Uint8Array> dataPtr);

late LcpWrapperNativeDecrypt fLcpWrapperNativeDecrypt;

class LcpClientNative extends LcpClient {
  static const int _maxLengthToDecrypt = 128 * 1024;
  static bool _isInitialized = false;

  @override
  bool get isAvailable => _isInitialized;

  static void loadDynamicLib() {
    if (Platform.isAndroid) {
      DynamicLibrary.open('libc++_shared.so');
      Fimber.d("<<<<<<<<<<<<<<<<<<<< DYNAMIC LIBRARY libc++_shared LOADED");
      DynamicLibrary.open('liblcp.so');
      Fimber.d("<<<<<<<<<<<<<<<<<<<< DYNAMIC LIBRARY liblcp LOADED");
      final DynamicLibrary nativeLcpWrapperlib =
          DynamicLibrary.open('liblcp_flutter.so');
      Fimber.d("<<<<<<<<<<<<<<<<<<<< DYNAMIC LIBRARY liblcp_flutter LOADED");
      _isInitialized = true;
      try {
        fLcpWrapperCreateContext = nativeLcpWrapperlib
            .lookupFunction<LcpWrapperCreateContext, LcpWrapperCreateContext>(
          "lcpWrapperCreateContext",
        );
        fLcpWrapperFindOneValidPassphrase = nativeLcpWrapperlib.lookupFunction<
            LcpWrapperFindOneValidPassphraseNative,
            LcpWrapperFindOneValidPassphrase>(
          "lcpWrapperFindOneValidPassphrase",
        );
        fLcpWrapperNativeDecrypt = nativeLcpWrapperlib
            .lookupFunction<LcpWrapperNativeDecrypt, LcpWrapperNativeDecrypt>(
          "lcpWrapperNativeDecrypt",
        );
      } catch (e, st) {
        Fimber.e("ERROR LCP", ex: e, stacktrace: st);
      }
    }
  }

  @override
  String findOneValidPassphrase(
      String jsonLicense, List<String> hashedPassphrases) {
    int errorCode = 0;
    Pointer<Utf8> foundHashedPassphrase = nullptr;

    try {
      foundHashedPassphrase = fLcpWrapperFindOneValidPassphrase(
          jsonLicense.toNativeUtf8(),
          StringList.fromList(hashedPassphrases).address);
    } catch (e, st) {
      Fimber.e("ERROR LCP", ex: e, stacktrace: st);
      // Unknown error
      errorCode = 500;
    }
    if (errorCode == 0 && foundHashedPassphrase == nullptr) {
      errorCode = 12;
    }
    DRMError drmError = fromCode(errorCode);
    if (drmError != DRMError.none) {
      throw DRMException(drmError);
    }
    String result = foundHashedPassphrase.toDartString();
    calloc.free(foundHashedPassphrase);
    return result;
  }

  @override
  DrmContext createContext(
      String jsonLicense, String hashedPassphrases, String pemCrl) {
    LcpDrmContext context = fLcpWrapperCreateContext(jsonLicense.toNativeUtf8(),
        hashedPassphrases.toNativeUtf8(), pemCrl.toNativeUtf8());
    int lcpDrmErrorCode = context.errorCode;

    DRMError error = fromCode(lcpDrmErrorCode);
    if (error != DRMError.none) {
      throw DRMException(error);
    }
    return DrmContext(
        context.hashedPassphrase.toDartString(),
        context.encryptedContentKey.toDartString(),
        context.token.toDartString(),
        context.profile.toDartString());
  }

  @override
  ByteData decrypt(DrmContext drmContext, ByteData encryptedData) {
    int offset = 0;
    List<int> rawData = [];
    while (offset < encryptedData.lengthInBytes) {
      Uint8List uint8list = encryptedData.buffer.asUint8List(offset,
          min(encryptedData.lengthInBytes - offset, _maxLengthToDecrypt));
      List<int> chunk = _decrypt(drmContext, uint8list);
      rawData.addAll(chunk);
      offset += _maxLengthToDecrypt;
    }
    return ByteData.sublistView(Uint8List.fromList(rawData));
  }

  List<int> _decrypt(DrmContext drmContext, Uint8List uint8list) {
    Pointer<Uint8Array> encryptedBytes = Uint8Array.fromData(uint8list);
    Pointer<LcpDrmContext> lcpDrmContextPtr = LcpDrmContext.allocate(
      hashedPassphrase: drmContext.hashedPassphrase,
      encryptedContentKey: drmContext.encryptedContentKey,
      token: drmContext.token,
      profile: drmContext.profile,
    );

    Uint8Array decryptResult =
        fLcpWrapperNativeDecrypt(lcpDrmContextPtr, encryptedBytes);
    DRMError error = fromCode(decryptResult.errorCode);
    if (error != DRMError.none) {
      throw DRMException(error);
    }
    return decryptResult.data;
  }
}

base class LcpDrmContext extends Struct {
  external Pointer<Utf8> hashedPassphrase;
  external Pointer<Utf8> encryptedContentKey;
  external Pointer<Utf8> token;
  external Pointer<Utf8> profile;
  @Int32()
  external int errorCode;

  static Pointer<LcpDrmContext> allocate({
    String? hashedPassphrase,
    String? encryptedContentKey,
    String? token,
    String? profile,
    int? errorCode,
  }) {
    Pointer<LcpDrmContext> pLcpDrmContext = calloc<LcpDrmContext>();
    pLcpDrmContext.ref.hashedPassphrase =
        hashedPassphrase?.toNativeUtf8() ?? nullptr;
    pLcpDrmContext.ref.encryptedContentKey =
        encryptedContentKey?.toNativeUtf8() ?? nullptr;
    pLcpDrmContext.ref.token = token?.toNativeUtf8() ?? nullptr;
    pLcpDrmContext.ref.profile = profile?.toNativeUtf8() ?? nullptr;
    pLcpDrmContext.ref.errorCode = errorCode ?? 0;
    return pLcpDrmContext;
  }

  @override
  String toString() =>
      'LCP_DRM_CONTEXT{hashedPassphrase: ${hashedPassphrase.address}, '
      'encryptedContentKey: ${encryptedContentKey.address}, '
      'token: ${token.address}, profile: ${profile.address}, '
      'errorCode: $errorCode}';
}

base class StringList extends Struct {
  external Pointer<Pointer<Utf8>> list;

  @Int64()
  external int size;

  static Pointer<StringList> fromList(List<String> arr) {
    Pointer<Pointer<Utf8>> list = calloc.allocate<Pointer<Utf8>>(arr.length);

    for (int i = 0; i < arr.length; i++) {
      list[i] = arr[i].toNativeUtf8();
    }

    Pointer<StringList> pStrList = calloc<StringList>();
    pStrList.ref.list = list;
    pStrList.ref.size = arr.length;

    return pStrList;
  }
}

base class Uint8Array extends Struct {
  external Pointer<Uint8> list;

  @Int64()
  external int size;

  @Int32()
  external int errorCode;

  static Pointer<Uint8Array> fromData(Uint8List uint8list) {
    Pointer<Uint8> bytes = calloc.allocate<Uint8>(uint8list.length);
    bytes.asTypedList(uint8list.length).setAll(0, uint8list);

    Pointer<Uint8Array> pStrList = calloc<Uint8Array>();
    pStrList.ref.list = bytes;
    pStrList.ref.size = uint8list.length;
    pStrList.ref.errorCode = 0;

    return pStrList;
  }

  List<int> get data => list.asTypedList(size);
}
