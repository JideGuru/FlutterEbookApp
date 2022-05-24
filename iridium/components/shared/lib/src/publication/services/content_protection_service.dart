// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';

abstract class ContentProtectionService extends PublicationService {
  /// Whether the [Publication] has a restricted access to its resources, and can't be rendered in
  /// a Navigator.
  bool get isRestricted;

  /// The error raised when trying to unlock the [Publication], if any.
  UserException? get error;

  /// Credentials used to unlock this [Publication].
  String? get credentials;

  /// Manages consumption of user rights and permissions.
  UserRights get rights;

  /// User-facing name for this Content Protection, e.g. "Readium LCP".
  /// It could be used in a sentence such as "Protected by {name}"
  LocalizedString? get name;

  @override
  List<Link> get links => RouteHandler.links;

  @override
  Resource? get(Link link) {
    RouteHandler? route = RouteHandler.route(link);
    if (route == null) {
      return null;
    }
    return route.handleRequest(link, this);
  }

  @override
  Type get serviceType => ContentProtectionService;
}

/// Manages consumption of user rights and permissions.
mixin UserRights {
  /// Returns whether the user is currently allowed to copy content to the pasteboard.
  ///
  /// Navigators and reading apps can use this to know if the "Copy" action should be greyed
  /// out or not. This should be called every time the "Copy" action will be displayed,
  /// because the value might change during runtime.
  bool get canCopy;

  /// Returns whether the user is allowed to copy the given text to the pasteboard.
  ///
  /// This is more specific than the [canCopy] property, and can return false if the given text
  /// exceeds the allowed amount of characters to copy.
  ///
  /// To be used before presenting, for example, a pop-up to share a selected portion of
  /// content.
  bool canCopyText(String text);

  /// Consumes the given text with the copy right.
  ///
  /// Returns whether the user is allowed to copy the given text.
  bool copy(String text);

  /// Returns whether the user is currently allowed to print the content.
  ///
  /// Navigators and reading apps can use this to know if the "Print" action should be greyed
  /// out or not.
  bool get canPrint;

  /// Returns whether the user is allowed to print the given amount of pages.
  ///
  /// This is more specific than the [canPrint] property, and can return false if the given
  /// [pageCount] exceeds the allowed amount of pages to print.
  ///
  /// To be used before attempting to launch a print job, for example.
  bool canPrintPageCount(int pageCount);

  /// Consumes the given amount of pages with the print right.
  ///
  /// Returns whether the user is allowed to print the given amount of pages.
  bool print(int pageCount);
}

/// A [UserRights] without any restriction.
class Unrestricted implements UserRights {
  @override
  bool get canCopy => true;

  @override
  bool canCopyText(String text) => true;

  @override
  bool get canPrint => true;

  @override
  bool canPrintPageCount(int pageCount) => true;

  @override
  bool copy(String text) => true;

  @override
  bool print(int pageCount) => true;
}

/// A [UserRights] which forbids any right.
class AllRestricted implements UserRights {
  @override
  bool get canCopy => false;

  @override
  bool canCopyText(String text) => false;

  @override
  bool get canPrint => false;

  @override
  bool canPrintPageCount(int pageCount) => false;

  @override
  bool copy(String text) => false;

  @override
  bool print(int pageCount) => false;
}

extension ServicesBuilderContentProtectionServiceExtension on ServicesBuilder {
  /// Factory to build a [ContentProtectionService].
  ServiceFactory? getContentProtectionServiceFactory() =>
      of<ContentProtectionService>();

  set contentProtectionServiceFactory(ServiceFactory serviceFactory) =>
      set<ContentProtectionService>(serviceFactory);
}

extension PublicationContentProtectionServiceExtension on Publication {
  ContentProtectionService? get protectionService {
    ContentProtectionService? contentProtectionService =
        findService<ContentProtectionService>();
    if (contentProtectionService != null) {
      return contentProtectionService;
    }
    /* TODO: return links.firstWithMediaType(RouteHandler.ContentProtectionHandler.link.mediaType!!)?.let {
            WebContentProtection(it)
        } */
    return null;
  }

  /// Returns whether this Publication is protected by a Content Protection technology.
  bool get isProtected => protectionService != null;

  /// Whether the [Publication] has a restricted access to its resources, and can't be rendered in
  /// a Navigator.
  bool get isRestricted => protectionService?.isRestricted ?? false;

  /// The error raised when trying to unlock the [Publication], if any.
  UserException? get protectionError => protectionService?.error;

  /// Credentials used to unlock this [Publication].
  String? get credentials => protectionService?.credentials;

  /// Manages consumption of user rights and permissions.
  UserRights get rights => protectionService?.rights ?? Unrestricted();

  /// User-facing localized name for this Content Protection, e.g. "Readium LCP".
  /// It could be used in a sentence such as "Protected by {name}".
  LocalizedString? get protectionLocalizedName => protectionService?.name;

  /// User-facing name for this Content Protection, e.g. "Readium LCP".
  /// It could be used in a sentence such as "Protected by {name}".
  String? get protectionName => protectionLocalizedName?.string;
}
