// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:archive/archive.dart';
import 'package:mno_shared/src/zip/file_buffer.dart';
import 'package:mno_shared/src/zip/lazy_zip_file_header.dart';

class LazyZipDirectory {
  // End of Central Directory Record
  static const int signature = 0x06054b50;
  static const int headerSignature = 0x04034b50;
  static const int zip64EocdLocatorSignature = 0x07064b50;
  static const int zip64EocdLocatorSize = 20;
  static const int zip64EocdSignature = 0x06064b50;
  static const int zip64EocdSize = 56;

  int filePosition = -1;
  int numberOfThisDisk = 0; // 2 bytes
  int diskWithTheStartOfTheCentralDirectory = 0; // 2 bytes
  int totalCentralDirectoryEntriesOnThisDisk = 0; // 2 bytes
  int totalCentralDirectoryEntries = 0; // 2 bytes
  late int centralDirectorySize; // 4 bytes
  late int centralDirectoryOffset; // 2 bytes
  String zipFileComment = ''; // 2 bytes, n bytes
  // Central Directory
  List<LazyZipFileHeader> fileHeaders = [];

  LazyZipDirectory();

  Future<void> load(FileBuffer input, {String? password}) async {
    if (!await headerSignatureValid(input)) {
      throw Exception("Not an archive");
    }

    filePosition = await _findSignature(input);
    input.position = filePosition;
    int signature = await input.readUint32(); // ignore: unused_local_variable
    numberOfThisDisk = await input.readUint16();
    diskWithTheStartOfTheCentralDirectory = await input.readUint16();
    totalCentralDirectoryEntriesOnThisDisk = await input.readUint16();
    totalCentralDirectoryEntries = await input.readUint16();
    centralDirectorySize = await input.readUint32();
    centralDirectoryOffset = await input.readUint32();

    int len = await input.readUint16();
    if (len > 0) {
      zipFileComment = await input.readString(len);
    }

    await _readZip64Data(input);

    InputStream dirContent =
        await input.subset(centralDirectoryOffset, centralDirectorySize);

    while (!dirContent.isEOS) {
      int fileSig = dirContent.readUint32();
      if (fileSig != LazyZipFileHeader.zipSignature) {
        break;
      }
      LazyZipFileHeader fileHeader = LazyZipFileHeader(fileSig);
      await fileHeader.load(dirContent, input, password);
      fileHeaders.add(fileHeader);
    }
  }

  Future<void> _readZip64Data(FileBuffer input) async {
    int ip = input.position;
    // Check for zip64 data.

    // Zip64 end of central directory locator
    // signature                       4 bytes  (0x07064b50)
    // number of the disk with the
    // start of the zip64 end of
    // central directory               4 bytes
    // relative offset of the zip64
    // end of central directory record 8 bytes
    // total number of disks           4 bytes

    int locPos = filePosition - zip64EocdLocatorSize;
    if (locPos < 0) {
      return;
    }
    InputStream zip64 = await input.subset(locPos, zip64EocdLocatorSize);

    int sig = zip64.readUint32();
    // If this ins't the signature we're looking for, nothing more to do.
    if (sig != zip64EocdLocatorSignature) {
      input.position = ip;
      return;
    }

    int startZip64Disk = zip64.readUint32(); // ignore: unused_local_variable
    int zip64DirOffset = zip64.readUint64();
    int numZip64Disks = zip64.readUint32(); // ignore: unused_local_variable

    input.position = zip64DirOffset;

    // Zip64 end of central directory record
    // signature                       4 bytes  (0x06064b50)
    // size of zip64 end of central
    // directory record                8 bytes
    // version made by                 2 bytes
    // version needed to extract       2 bytes
    // number of this disk             4 bytes
    // number of the disk with the
    // start of the central directory  4 bytes
    // total number of entries in the
    // central directory on this disk  8 bytes
    // total number of entries in the
    // central directory               8 bytes
    // size of the central directory   8 bytes
    // offset of start of central
    // directory with respect to
    // the starting disk number        8 bytes
    // zip64 extensible data sector    (variable size)
    sig = await input.readUint32();
    if (sig != zip64EocdSignature) {
      input.position = ip;
      return;
    }

    // ignore: unused_local_variable
    int zip64EOCDSize = await input.readUint64();
    // ignore: unused_local_variable
    int zip64Version = await input.readUint16();
    // ignore: unused_local_variable
    int zip64VersionNeeded = await input.readUint16();
    int zip64DiskNumber = await input.readUint32();
    int zip64StartDisk = await input.readUint32();
    int zip64NumEntriesOnDisk = await input.readUint64();
    int zip64NumEntries = await input.readUint64();
    int dirSize = await input.readUint64();
    int dirOffset = await input.readUint64();

    numberOfThisDisk = zip64DiskNumber;
    diskWithTheStartOfTheCentralDirectory = zip64StartDisk;
    totalCentralDirectoryEntriesOnThisDisk = zip64NumEntriesOnDisk;
    totalCentralDirectoryEntries = zip64NumEntries;
    centralDirectorySize = dirSize;
    centralDirectoryOffset = dirOffset;

    input.position = ip;
  }

  Future<int> _findSignature(FileBuffer input) async {
    int pos = input.position;
    int length = input.length;

    // The directory and archive contents are written to the end of the zip
    // file.  We need to search from the end to find these structures,
    // starting with the 'End of central directory' record (EOCD).
    for (int ip = length - 4; ip >= 0; --ip) {
      input.position = ip;
      int sig = await input.readUint32();
      if (sig == signature) {
        input.position = pos;
        return ip;
      }
    }

    throw ArchiveException('Could not find End of Central Directory Record');
  }

  Future<bool> headerSignatureValid(FileBuffer input) async {
    int sig = await input.readUint32();
    input.position = 0;
    return sig == headerSignature;
  }
}
