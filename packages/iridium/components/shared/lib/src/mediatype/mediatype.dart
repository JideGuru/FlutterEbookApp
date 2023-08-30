// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:meta/meta.dart';
import 'package:mno_commons/utils/take.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' hide Link;

/// Represents a document format, identified by a unique RFC 6838 media type.
///
/// [MediaType] handles:
///  - components parsing – eg. type, subtype and parameters,
///  - media types comparison.
///
/// Comparing media types is more complicated than it looks, since they can contain parameters,
/// such as `charset=utf-8`. We can't ignore them because some formats use parameters in their
/// media type, for example `application/atom+xml;profile=opds-catalog` for an OPDS 1 catalog.
///
/// Specification: https://tools.ietf.org/html/rfc6838
///
/// @param string String representation for this media type.
/// @param name A human readable name identifying the media type, which may be presented to the user.
/// @param fileExtension The default file extension to use for this media type.
class MediaType {
  final String? name;
  final String? fileExtension;

  /// The type component, e.g. `application` in `application/epub+zip`.
  final String type;

  /// The subtype component, e.g. `epub+zip` in `application/epub+zip`.
  final String subtype;

  /// The parameters in the media type, such as `charset=utf-8`.
  final Map<String, String> parameters;

  @protected
  const MediaType(
      {this.name,
      this.fileExtension,
      required this.type,
      required this.subtype,
      this.parameters = const {}});

  static const MediaType aac =
      MediaType(type: "audio", subtype: "aac", fileExtension: "aac");
  static const MediaType v3g2 =
      MediaType(type: "video", subtype: "3g2", fileExtension: "3g2");
  static const MediaType v3gp =
      MediaType(type: "video", subtype: "3gp", fileExtension: "3gp");
  static const MediaType acsm = MediaType(
      type: "application",
      subtype: "vnd.adobe.adept+xml",
      name: "Adobe Content Server Message",
      fileExtension: "acsm");
  static const MediaType aiff =
      MediaType(type: "audio", subtype: "aiff", fileExtension: "aiff");
  static const MediaType avi =
      MediaType(type: "video", subtype: "x-msvideo", fileExtension: "avi");
  static const MediaType binary =
      MediaType(type: "application", subtype: "octet-stream");
  static const MediaType bmp =
      MediaType(type: "image", subtype: "bmp", fileExtension: "bmp");
  static const MediaType cbz = MediaType(
      type: "application",
      subtype: "vnd.comicbook+zip",
      name: "Comic Book Archive",
      fileExtension: "cbz");
  static const MediaType css =
      MediaType(type: "text", subtype: "css", fileExtension: "css");
  static const MediaType divina = MediaType(
      type: "application",
      subtype: "divina+zip",
      name: "Digital Visual Narratives",
      fileExtension: "divina");
  static const MediaType divinaManifest = MediaType(
      type: "application",
      subtype: "divina+json",
      name: "Digital Visual Narratives",
      fileExtension: "json");
  static const MediaType doc =
      MediaType(type: "application", subtype: "msword", fileExtension: "doc");
  static const MediaType docx = MediaType(
      type: "application",
      subtype: "vnd.openxmlformats-officedocument.wordprocessingml.document",
      fileExtension: "docx");
  static const MediaType epub = MediaType(
      type: "application",
      subtype: "epub+zip",
      name: "EPUB",
      fileExtension: "epub");
  static const MediaType gif =
      MediaType(type: "image", subtype: "gif", fileExtension: "gif");
  static const MediaType gz =
      MediaType(type: "application", subtype: "gzip", fileExtension: "gz");
  static const MediaType html =
      MediaType(type: "text", subtype: "html", fileExtension: "html");
  static const MediaType javascript =
      MediaType(type: "text", subtype: "javascript", fileExtension: "js");
  static const MediaType jpeg =
      MediaType(type: "image", subtype: "jpeg", fileExtension: "jpeg");
  static const MediaType json = MediaType(type: "application", subtype: "json");
  static const MediaType lcpLicenseDocument = MediaType(
      type: "application",
      subtype: "vnd.readium.lcp.license.v1.0+json",
      name: "LCP License",
      fileExtension: "lcpl");
  static const MediaType lcpProtectedAudiobook = MediaType(
      type: "application",
      subtype: "audiobook+lcp",
      name: "LCP Protected Audiobook",
      fileExtension: "lcpa");
  static const MediaType lcpProtectedPdf = MediaType(
      type: "application",
      subtype: "pdf+lcp",
      name: "LCP Protected PDF",
      fileExtension: "lcpdf");
  static const MediaType lcpStatusDocument = MediaType(
      type: "application", subtype: "vnd.readium.license.status.v1.0+json");
  static const MediaType lpf =
      MediaType(type: "application", subtype: "lpf+zip", fileExtension: "lpf");
  static const MediaType mp3 =
      MediaType(type: "audio", subtype: "mpeg", fileExtension: "mp3");

  static const MediaType mp4 =
      MediaType(type: "video", subtype: "mp4", fileExtension: "mp4");
  static const MediaType mp4a =
      MediaType(type: "video", subtype: "mp4", fileExtension: "m4a");
  static const MediaType mpeg =
      MediaType(type: "video", subtype: "mpeg", fileExtension: "mpeg");
  static const MediaType mpg =
      MediaType(type: "video", subtype: "mpg", fileExtension: "mpg");
  static const MediaType mkv =
      MediaType(type: "video", subtype: "mkv", fileExtension: "mkv");
  static const MediaType mov =
      MediaType(type: "video", subtype: "mov", fileExtension: "mov");
  static const MediaType ncx = MediaType(
      type: "application", subtype: "x-dtbncx+xml", fileExtension: "ncx");
  static const MediaType oga =
      MediaType(type: "application", subtype: "ogg", fileExtension: "oga");
  static const MediaType ogg =
      MediaType(type: "application", subtype: "ogg", fileExtension: "ogg");
  static const MediaType ogv =
      MediaType(type: "video", subtype: "ogg", fileExtension: "ogv");
  static const MediaType opds1 = MediaType(
      type: "application",
      subtype: "atom+xml",
      parameters: {"profile": "opds-catalog"});
  static const MediaType opds1Entry = MediaType(
      type: "application",
      subtype: "atom+xml",
      parameters: {"type": "entry", "profile": "opds-catalog"});
  static const MediaType opds2 =
      MediaType(type: "application", subtype: "opds+json");
  static const MediaType opds2Publication =
      MediaType(type: "application", subtype: "opds-publication+json");
  static const MediaType opdsAuthentication =
      MediaType(type: "application", subtype: "opds-authentication+json");
  static const MediaType opus =
      MediaType(type: "audio", subtype: "opus", fileExtension: "opus");
  static const MediaType otf =
      MediaType(type: "font", subtype: "otf", fileExtension: "otf");
  static const MediaType pdf = MediaType(
      type: "application", subtype: "pdf", name: "PDF", fileExtension: "pdf");
  static const MediaType png =
      MediaType(type: "image", subtype: "png", fileExtension: "png");
  static const MediaType readiumAudiobook = MediaType(
      type: "application",
      subtype: "audiobook+zip",
      name: "Readium Audiobook",
      fileExtension: "audiobook");
  static const MediaType readiumAudiobookManifest = MediaType(
      type: "application",
      subtype: "audiobook+json",
      name: "Readium Audiobook",
      fileExtension: "json");
  static const MediaType readiumWebpub = MediaType(
      type: "application",
      subtype: "webpub+zip",
      name: "Readium Web Publication",
      fileExtension: "webpub");
  static const MediaType readiumWebpubManifest = MediaType(
      type: "application",
      subtype: "webpub+json",
      name: "Readium Web Publication",
      fileExtension: "json");
  static const MediaType smil = MediaType(
      type: "application", subtype: "smil+xml", fileExtension: "smil");
  static const MediaType svg =
      MediaType(type: "image", subtype: "svg+xml", fileExtension: "svg");
  static const MediaType text =
      MediaType(type: "text", subtype: "plain", fileExtension: "txt");
  static const MediaType tiff =
      MediaType(type: "image", subtype: "tiff", fileExtension: "tiff");
  static const MediaType ttf =
      MediaType(type: "font", subtype: "ttf", fileExtension: "ttf");
  static const MediaType w3cWpubManifest = MediaType(
      type: "application",
      subtype: "x.readium.w3c.wpub+json",
      name: "Web Publication",
      fileExtension: "json"); // non-existent
  static const MediaType wav =
      MediaType(type: "audio", subtype: "wav", fileExtension: "wav");
  static const MediaType webmAudio =
      MediaType(type: "audio", subtype: "webm", fileExtension: "weba");
  static const MediaType webmVideo =
      MediaType(type: "video", subtype: "webm", fileExtension: "webm");
  static const MediaType webp =
      MediaType(type: "image", subtype: "webp", fileExtension: "webp");
  static const MediaType woff =
      MediaType(type: "font", subtype: "woff", fileExtension: "woff");
  static const MediaType woff2 =
      MediaType(type: "font", subtype: "woff2", fileExtension: "woff2");
  static const MediaType xhtml = MediaType(
      type: "application", subtype: "xhtml+xml", fileExtension: "xhtml");
  static const MediaType xaiff =
      MediaType(type: "audio", subtype: "xaiff", fileExtension: "aif");
  static const MediaType xaiffc =
      MediaType(type: "audio", subtype: "xaiff", fileExtension: "aifc");
  static const MediaType xlsx = MediaType(
      type: "application",
      subtype: "vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      fileExtension: "xlsx");
  static const MediaType xls = MediaType(
      type: "application", subtype: "vnd.ms-excel", fileExtension: "xls");

  static const MediaType pptx = MediaType(
      type: "application",
      subtype: "vnd.openxmlformats-officedocument.presentationml.presentation",
      fileExtension: "pptx");
  static const MediaType ppt = MediaType(
      type: "application", subtype: "vnd.ms-powerpoint", fileExtension: "ppt");

  static const MediaType xml =
      MediaType(type: "application", subtype: "xml", fileExtension: "xml");
  static const MediaType xmpegurl =
      MediaType(type: "audio", subtype: "mpeg", fileExtension: "m3u");

  static const MediaType zab = MediaType(
      type: "application",
      subtype: "x.readium.zab+zip",
      name: "Zipped Audio Book",
      fileExtension: "zab"); // non-existent
  static const MediaType zip =
      MediaType(type: "application", subtype: "zip", fileExtension: "zip");

  static const MediaType waveform =
      MediaType(type: "image", subtype: "png", fileExtension: "wave");

  static final List<MediaType> _values = [
    aac,
    acsm,
    aiff,
    avi,
    binary,
    bmp,
    cbz,
    css,
    divina,
    divinaManifest,
    doc,
    docx,
    epub,
    gif,
    gz,
    html,
    javascript,
    jpeg,
    json,
    lcpLicenseDocument,
    lcpProtectedAudiobook,
    lcpProtectedPdf,
    lcpStatusDocument,
    lpf,
    mov,
    mp3,
    mp4,
    mpeg,
    ncx,
    oga,
    ogg,
    ogv,
    opds1,
    opds1Entry,
    opds2,
    opds2Publication,
    opdsAuthentication,
    opus,
    otf,
    pdf,
    png,
    ppt,
    pptx,
    readiumAudiobook,
    readiumAudiobookManifest,
    readiumWebpub,
    readiumWebpubManifest,
    smil,
    svg,
    text,
    tiff,
    ttf,
    v3g2,
    v3gp,
    w3cWpubManifest,
    wav,
    webmAudio,
    webmVideo,
    webp,
    woff,
    woff2,
    xaiff,
    xaiffc,
    xhtml,
    xhtml,
    xhtml,
    xml,
    xmpegurl,
    xls,
    xlsx,
    zab,
    zip,
  ];

  /// Creates a [MediaType] from its string representation.
  static MediaType? parse(String string,
      {String? name, String? fileExtension}) {
    try {
      return MediaType._create(string,
          name: name, fileExtension: fileExtension);
    } on Error catch (e, stacktrace) {
      Fimber.e("MediaType._create ERROR", ex: e, stacktrace: stacktrace);
      return null;
    }
  }

  factory MediaType._create(String string,
      {String? name, String? fileExtension}) {
    if (string.isEmpty) {
      throw ArgumentError("Invalid media type: $string");
    }
    // Grammar: https://tools.ietf.org/html/rfc2045#section-5.1
    List<String> components = string.split(";").map((it) => it.trim()).toList();
    List<String> types = components[0].split("/");
    if (types.length != 2) {
      throw ArgumentError("Invalid media type: $string");
    }

    // > Both top-level type and subtype names are case-insensitive.
    String type = types[0].toLowerCase();
    String subtype = types[1].toLowerCase();

    // > Parameter names are case-insensitive and no meaning is attached to the order in which
    // > they appear.
    Map<String, String> parameters = components
        .sublist(1)
        .map((it) => it.split("="))
        .where((it) => it.length == 2)
        .fold(
            {},
            (previousValue, it) =>
                previousValue..[it[0].toLowerCase()] = it[1]);

    // For now, we only support case-insensitive `charset`.
    //
    // > Parameter values might or might not be case-sensitive, depending on the semantics of
    // > the parameter name.
    // > https://tools.ietf.org/html/rfc2616#section-3.7
    //
    // > The character set names may be up to 40 characters taken from the printable characters
    // > of US-ASCII.  However, no distinction is made between use of upper and lower case
    // > letters.
    // > https://www.iana.org/assignments/character-sets/character-sets.xhtml
    parameters["charset"]?.let((it) =>
        parameters["charset"] = Charset.forName(it)?.name ?? it.toUpperCase());

    return MediaType(
        name: name,
        fileExtension: fileExtension,
        type: type,
        subtype: subtype,
        parameters: parameters);
  }

  /// Structured syntax suffix, e.g. `+zip` in `application/epub+zip`.
  ///
  /// Gives a hint on the underlying structure of this media type.
  /// See. https://tools.ietf.org/html/rfc6838#section-4.2.8
  String? get structuredSyntaxSuffix {
    List<String> parts = subtype.split("+");
    return (parts.length > 1) ? "+${parts.last}" : null;
  }

  /// Encoding as declared in the `charset` parameter, if there's any.
  String? get charset => parameters["charset"];

  /// Returns the canonical version of this media type, if it is known.
  ///
  /// This is useful to find the name and file extension of a known media type, or to get the
  /// canonical media type from an alias. For example, `application/x-cbz` is an alias of the
  /// canonical `application/vnd.comicbook+zip`.
  ///
  /// Non-significant parameters are also discarded.
  Future<MediaType> canonicalMediaType() async =>
      (await ofSingleHint(mediaType: toString())) ?? this;

  /// The string representation of this media type.
  @override
  String toString() {
    List<String> params = parameters.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();
    params.sort((a, b) => a.compareTo(b));
    String paramsStr = "";
    if (params.isNotEmpty) {
      paramsStr = ";${params.join(";")}";
    }
    return "$type/$subtype$paramsStr";
  }

  /// Returns whether two media types are equal, checking the type, subtype and parameters.
  /// Parameters order is ignored.
  ///
  /// WARNING: Strict media type comparisons can be a source of bug, if parameters are present.
  /// `text/html` != `text/html;charset=utf-8` with strict equality comparison, which is most
  /// likely not the desired result. Instead, you can use [matches] to check if any of the media
  /// types is a parameterized version of the other one.
  @override
  bool operator ==(Object other) =>
      toString() == (other as MediaType?)?.toString();

  @override
  int get hashCode => type.hashCode ^ subtype.hashCode ^ parameters.hashCode;

  /// Returns whether the given [other] media type is included in this media type.
  ///
  /// For example, `text/html` contains `text/html;charset=utf-8`.
  ///
  /// - [other] must match the parameters in the [parameters] property, but extra parameters
  ///    are ignored.
  /// - Order of parameters is ignored.
  /// - Wildcards are supported, meaning that `image/*` contains `image/png` and `*/*` contains
  ///   everything.
  bool contains(MediaType? other) {
    if (other == null ||
        (type != "*" && type != other.type) ||
        (subtype != "*" && subtype != other.subtype)) {
      return false;
    }
    Set<String> paramsSet =
        parameters.entries.map((e) => "${e.key}=${e.value}").toSet();
    Set<String> otherParamsSet =
        other.parameters.entries.map((e) => "${e.key}=${e.value}").toSet();
    return otherParamsSet.containsAll(paramsSet);
  }

  /// Returns whether the given [other] media type is included in this media type.
  bool containsFromName(String? other) {
    MediaType? mediaType = other?.let((it) => MediaType.parse(it));
    if (mediaType == null) {
      return false;
    }
    return contains(mediaType);
  }

  /// Returns whether this media type and `other` are the same, ignoring parameters that are not
  /// in both media types.
  ///
  /// For example, `text/html` matches `text/html;charset=utf-8`, but `text/html;charset=ascii`
  /// doesn't. This is basically like `contains`, but working in both direction.
  bool matches(MediaType? other) =>
      contains(other) || (other?.contains(this) == true);

  /// Returns whether this media type and `other` are the same, ignoring parameters that are not
  /// in both media types.
  bool matchesFromName(String? other) => matches(other?.let((it) => parse(it)));

  /// Returns whether this media type matches any of the `others` media types.
  bool matchesAny(Iterable<MediaType> others) =>
      others.any((it) => matches(it));

  /// Returns whether this media type matches any of the `others` media types.
  bool matchesAnyFromName(Iterable<String> others) =>
      others.any((it) => matchesFromName(it));

  /// Returns whether this media type is structured as a ZIP archive.
  bool get isZip =>
      matchesAny([zip, lcpProtectedAudiobook, lcpProtectedPdf]) ||
      structuredSyntaxSuffix == "+zip";

  /// Returns whether this media type is structured as a JSON file.
  bool get isJson => matches(json) || structuredSyntaxSuffix == "+json";

  /// Returns whether this media type is of an OPDS feed.
  bool get isOpds => matchesAny(
      [opds1, opds1Entry, opds2, opds2Publication, opdsAuthentication]);

  /// Returns whether this media type is of an HTML document.
  bool get isHtml => matchesAny([html, xhtml]);

  /// Returns whether this media type is of a bitmap image, so excluding vectorial formats.
  bool get isBitmap => matchesAny([bmp, gif, jpeg, png, tiff, webp, waveform]);

  /// Returns whether this media type is of an audio clip.
  bool get isAudio => type == "audio" || matchesAny([ogg, oga]);

  /// Returns whether this media type is of a video clip.
  bool get isVideo => type == "video";

  /// Returns whether this media type is of a Readium Web Publication Manifest.
  bool get isRwpm => matchesAny(
      [readiumAudiobookManifest, divinaManifest, readiumWebpubManifest]);

  /// Returns whether this media type is of a publication file.
  bool get isPublication => matchesAny([
        readiumAudiobook,
        readiumAudiobookManifest,
        cbz,
        divina,
        divinaManifest,
        epub,
        lcpProtectedAudiobook,
        lcpProtectedPdf,
        lpf,
        pdf,
        w3cWpubManifest,
        readiumWebpub,
        readiumWebpubManifest,
        zab
      ]);

  /// The default sniffers provided by Readium 2 to resolve a [MediaType].
  /// You can register additional sniffers globally by modifying this list.
  /// The sniffers order is important, because some formats are subsets of other formats.
  static const List<Sniffer> sniffers = Sniffers.all;

  /// Resolves a format from a single file extension and media type hint, without checking the actual
  /// content.
  static Future<MediaType?> ofSingleHint(
          {String? mediaType,
          String? fileExtension,
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      _of(
          content: null,
          mediaTypes: [mediaType].whereNotNull().toList(),
          fileExtensions: [fileExtension].whereNotNull().toList(),
          sniffers: sniffers);

  /// Resolves a format from file extension and media type hints, without checking the actual
  /// content.
  static Future<MediaType?> of(
          {List<String> mediaTypes = const [],
          List<String> fileExtensions = const [],
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      _of(
          content: null,
          mediaTypes: mediaTypes,
          fileExtensions: fileExtensions,
          sniffers: sniffers);

  /// Resolves a format from a local file path.
  static Future<MediaType?> ofFileWithSingleHint(FileSystemEntity file,
          {String? mediaType,
          String? fileExtension,
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      ofFile(file,
          mediaTypes: [mediaType].whereNotNull().toList(),
          fileExtensions: [fileExtension].whereNotNull().toList(),
          sniffers: sniffers);

  /// Resolves a format from a local file path.
  static Future<MediaType?> ofFile(FileSystemEntity file,
          {List<String> mediaTypes = const [],
          List<String> fileExtensions = const [],
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      _of(
          content: SnifferFileContent(file),
          mediaTypes: mediaTypes,
          fileExtensions: [file.path.extension(), ...fileExtensions],
          sniffers: sniffers);

  /// Resolves a format from a local file path.
  static Future<MediaType?> ofFilePathWithSingleHint(String path,
          {String? mediaType,
          String? fileExtension,
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      ofFileWithSingleHint(File(path),
          mediaType: mediaType,
          fileExtension: fileExtension,
          sniffers: sniffers);

  /// Resolves a format from a local file path.
  static Future<MediaType?> ofFilePath(String path,
          {List<String> mediaTypes = const [],
          List<String> fileExtensions = const [],
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      ofFile(File(path),
          mediaTypes: mediaTypes,
          fileExtensions: fileExtensions,
          sniffers: sniffers);

  /// Resolves a format from bytes, e.g. from an HTTP response.
  static Future<MediaType?> ofBytesWithSingleHint(
          Future<ByteData> Function() bytes,
          {String? mediaType,
          String? fileExtension,
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      ofBytes(bytes,
          mediaTypes: [mediaType].whereNotNull().toList(),
          fileExtensions: [fileExtension].whereNotNull().toList(),
          sniffers: sniffers);

  /// Resolves a format from bytes, e.g. from an HTTP response.
  static Future<MediaType?> ofBytes(Future<ByteData> Function() bytes,
          {List<String> mediaTypes = const [],
          List<String> fileExtensions = const [],
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      _of(
          content: SnifferBytesContent(bytes),
          mediaTypes: mediaTypes,
          fileExtensions: fileExtensions,
          sniffers: sniffers);

  /// Resolves a format from a content URI and a [ContentResolver].
  /// Accepts the following URI schemes: content, android.resource, file.
  static Future<MediaType?> ofUriWithSingleHint(Uri uri,
          {String? mediaType,
          String? fileExtension,
          List<Sniffer> sniffers = MediaType.sniffers}) =>
      ofUri(uri,
          mediaTypes: [mediaType].whereNotNull().toList(),
          fileExtensions: [fileExtension].whereNotNull().toList(),
          sniffers: sniffers);

  /// Resolves a format from a content URI and a [ContentResolver].
  /// Accepts the following URI schemes: content, android.resource, file.
  static Future<MediaType?> ofUri(Uri uri,
      {List<String> mediaTypes = const [],
      List<String> fileExtensions = const [],
      List<Sniffer> sniffers = MediaType.sniffers}) {
    List<String> allMediaTypes = List.of(mediaTypes);
    List<String> allFileExtensions =
        fileExtensions.map((ext) => ext.extension()).toList();

    uri.path
        .extension()
        .takeIf((it) => it.isNotEmpty)
        ?.let((it) => allFileExtensions.insert(0, it));

    SnifferContent content = SnifferUriContent(uri);
    return _of(
        content: content,
        mediaTypes: allMediaTypes,
        fileExtensions: allFileExtensions,
        sniffers: sniffers);
  }

  /// Resolves a media type from a sniffer context.
  ///
  /// Sniffing a media type is done in two rounds, because we want to give an opportunity to all
  /// sniffers to return a [MediaType] quickly before inspecting the content itself:
  ///  - Light Sniffing checks only the provided file extension or media type hints.
  ///  - Heavy Sniffing reads the bytes to perform more advanced sniffing.
  static Future<MediaType?> _of(
      {SnifferContent? content,
      List<String> mediaTypes = const [],
      List<String> fileExtensions = const [],
      List<Sniffer> sniffers = MediaType.sniffers}) async {
    // Light sniffing
    SnifferContext context =
        SnifferContext(mediaTypes: mediaTypes, fileExtensions: fileExtensions);
    for (Sniffer sniffer in sniffers) {
      MediaType? mediaType = await sniffer(context);
      if (mediaType != null) {
        return mediaType;
      }
    }

    // Heavy sniffing
    if (content != null) {
      context = SnifferContext(
          content: content,
          mediaTypes: mediaTypes,
          fileExtensions: fileExtensions);
      for (Sniffer sniffer in sniffers) {
        MediaType? mediaType = await sniffer(context);
        if (mediaType != null) {
          return mediaType;
        }
      }
    }
    //
    // // Falls back on the system-wide registered media types using [MimeTypeMap].
    // // Note: This is done after the heavy sniffing of the provided [sniffers], because
    // // otherwise it will detect JSON, XML or ZIP formats before we have a chance of sniffing
    // // their content (for example, for RWPM).
    // Sniffers.system(context)?.let { return it }
    //
    // // If nothing else worked, we try to parse the first valid media type hint.
    for (String mt in mediaTypes) {
      MediaType? mediaType = parse(mt);
      if (mediaType != null) {
        return mediaType;
      }
    }
    for (String fileExtension in fileExtensions) {
      MediaType? mediaType = filterByFileExtension(fileExtension);
      if (mediaType != null) {
        return mediaType;
      }
    }

    return null;
  }

  static MediaType? filterByFileExtension(String? fileExtension) =>
      fileExtension?.let((it) {
        for (MediaType mediaType in _values) {
          if (it == mediaType.fileExtension) {
            return mediaType;
          }
        }
        return null;
      });

  static void addSupportedType(MediaType mediaType) => _values.add(mediaType);
}

extension StringPathExtension on String {
  String extension() => p.extension(this).removePrefix('.');
}
