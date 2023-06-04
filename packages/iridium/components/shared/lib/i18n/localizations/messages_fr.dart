// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = Function(String messageStr, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'fr';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_shared_publication_opening_exception_error":
            MessageLookupByLibrary.simpleMessage("Error opening document"),
        "r2_shared_publication_opening_exception_unsupported_format":
            MessageLookupByLibrary.simpleMessage("Format not supported"),
        "r2_shared_publication_opening_exception_not_found":
            MessageLookupByLibrary.simpleMessage("File not found"),
        "r2_shared_publication_opening_exception_parsing_failed":
            MessageLookupByLibrary.simpleMessage(
                "The file is corrupted and can't be opened"),
        "r2_shared_publication_opening_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "You are not allowed to open this publication"),
        "r2_shared_publication_opening_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Not available, please try again later"),
        "r2_shared_publication_opening_exception_incorrect_credentials":
            MessageLookupByLibrary.simpleMessage(
                "Provided credentials were incorrect"),
        "r2_shared_resource_exception_bad_request":
            MessageLookupByLibrary.simpleMessage(
                "Invalid request which can't be processed"),
        "r2_shared_resource_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Resource not found"),
        "r2_shared_resource_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "You are not allowed to access the resource"),
        "r2_shared_resource_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "The resource is currently unavailable, please try again later"),
        "r2_shared_resource_exception_out_of_memory":
            MessageLookupByLibrary.simpleMessage(
                "The resource is too large to be read on this device"),
        "r2_shared_resource_exception_cancelled":
            MessageLookupByLibrary.simpleMessage("The request was cancelled"),
        "r2_shared_resource_exception_other":
            MessageLookupByLibrary.simpleMessage("A service error occurred"),
      };
}
