// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

extension PublicationLists on Publication {
  /// Provides navigation to positions in the Publication content that correspond to the locations of
  /// page boundaries present in a print source being represented by this EPUB Publication.
  List<Link> get pageList => linksWithRole("pageList");

  /// Identifies fundamental structural components of the publication in order to enable Reading
  /// Systems to provide the User efficient access to them.
  List<Link> get landmarks => linksWithRole("landmarks");

  List<Link> get listOfAudioClips => linksWithRole("loa");
  List<Link> get listOfIllustrations => linksWithRole("loi");
  List<Link> get listOfTables => linksWithRole("lot");
  List<Link> get listOfVideoClips => linksWithRole("lov");
}
