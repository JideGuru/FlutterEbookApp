// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String settingsPrefix = "org.readium.r2.settings";
  static const String lcpDeviceIdPref = settingsPrefix + ".lcp_device_id";
  final DeviceRepository repository;
  final NetworkService network;
  final SharedPreferences preferences;

  DeviceService(this.repository, this.network, this.preferences);

  String get id {
    String deviceId = const Uuid().v1();
    if (preferences.containsKey(lcpDeviceIdPref)) {
      var prefValue = preferences.getString(lcpDeviceIdPref);
      if (prefValue != null) {
        deviceId = prefValue;
      }
    }
    preferences.setString(lcpDeviceIdPref, deviceId);
    return deviceId;
  }

  Future<String> get name async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return Platform.operatingSystem;
  }

  Future<Map<String, String>> get asQueryParameters async => {
        'id': id,
        'name': await name,
      };

  Future<ByteData?> registerLicense(LicenseDocument license, Link link) async {
    if (await repository.isDeviceRegistered(license)) {
      return null;
    }

    String url =
        link.urlWithParams(parameters: await asQueryParameters).toString();
    ByteData? data = (await network.fetch(url,
            method: Method.post, parameters: await asQueryParameters))
        .getOrNull();
    if (data == null) {
      return null;
    }

    repository.registerDevice(license);
    return data;
  }
}
