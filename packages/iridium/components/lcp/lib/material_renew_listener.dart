// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mno_lcp/lcp.dart';
import 'package:url_launcher/url_launcher.dart';

/// A default implementation of the [RenewListener] using Chrome Custom Tabs for
/// presenting web pages and a Material Date Picker for choosing the renew date.
///
/// [MaterialRenewListener] must be initialized before its parent component is in a RESUMED state,
/// because it needs to register an ActivityResultLauncher.
///
/// @param [license] LCP license which will be renewed.
/// @param [context] [BuildContext] used to present the date picker.
class MaterialRenewListener implements RenewListener {
  final LcpLicense? license;
  final BuildContext context;

  MaterialRenewListener(this.license, this.context);

  @override
  Future<DateTime> preferredEndDate(DateTime? maximumDate) async {
    if (license == null) {
      return DateTime.now();
    }
    DateTime start = (license!.license.rights.end ?? DateTime.now());
    DateTime end = maximumDate ?? DateTime.now().add(const Duration(days: 365));
    return await showDatePicker(
            context: context,
            initialDate: start,
            firstDate: start,
            lastDate: end) ??
        start;
  }

  @override
  Future<bool> openWebPage(Uri url) async {
    if (await canLaunchUrl(url)) {
      return launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
