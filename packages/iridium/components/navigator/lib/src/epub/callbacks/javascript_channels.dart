// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

typedef HandlerCallback = dynamic Function(List<dynamic> arguments);

abstract class JavascriptChannels {
  Map<String, HandlerCallback> get channels;
}
