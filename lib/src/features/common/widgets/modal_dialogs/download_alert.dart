import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class DownloadAlert extends ConsumerStatefulWidget {
  final String url;
  final String name;
  final String image;
  final String id;

  const DownloadAlert({
    super.key,
    required this.url,
    required this.name,
    required this.image,
    required this.id,
  });

  static Future show({
    required BuildContext context,
    required String url,
    required String name,
    required String image,
    required String id,
  }) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        name: name,
        image: image,
        id: id,
      ),
    );
  }

  @override
  _DownloadAlertState createState() => _DownloadAlertState();
}

class _DownloadAlertState extends ConsumerState<DownloadAlert> {
  Dio dio = Dio();
  int received = 0;
  String progress = '0';
  int total = 0;

  String get fileName =>
      widget.name.replaceAll(' ', '_').replaceAll(r"\'", "'");

  Future<void> checkPermissionAndDownload() async {
    if (kIsWeb || Platform.isMacOS) {
      createFile();
      return;
    }

    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      // access media location needed for android 10/Q
      await Permission.accessMediaLocation.request();
      // manage external storage needed for android 11/R
      await Permission.manageExternalStorage.request();
      createFile();
    } else {
      createFile();
    }
  }

  Future<void> createFile() async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String dirPath = path.join(appDocDir!.path, Strings.appName);
    if (Platform.isAndroid) {
      Directory(appDocDir.path.split('Android')[0] + Strings.appName)
          .createSync();
    } else {
      Directory(dirPath).createSync();
    }
    String filePath = Platform.isAndroid
        ? path.join(
            appDocDir.path.split('Android')[0],
            Strings.appName,
            '$fileName.epub',
          )
        : path.join(dirPath, '$fileName.epub');
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create();
    } else {
      await file.delete();
      await file.create();
    }

    download(filePath: filePath);
  }

  Future<void> download({required String filePath}) async {
    await dio.download(
      widget.url,
      filePath,
      deleteOnError: true,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          received = receivedBytes;
          total = totalBytes;
          progress = (received / total * 100).toStringAsFixed(0);
        });

        //Check if download is complete and close the alert dialog
        if (receivedBytes == totalBytes) {
          String size = '${Utils.formatBytes(total, 1)}';
          Map<String, dynamic> book = {
            'id': widget.id,
            'path': filePath,
            'image': widget.image,
            'size': size,
            'name': widget.name,
          };

          ref
              .read(downloadsStateNotifierProvider.notifier)
              .addBook(book, widget.id);
          Navigator.pop(context, size);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkPermissionAndDownload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Downloading...',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20.0),
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: LinearProgressIndicator(
                  value: double.parse(progress) / 100.0,
                  valueColor: AlwaysStoppedAnimation(
                    context.theme.colorScheme.secondary,
                  ),
                  backgroundColor:
                      context.theme.colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$progress %',
                    style: const TextStyle(
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${Utils.formatBytes(received, 1)} '
                    'of ${Utils.formatBytes(total, 1)}',
                    style: const TextStyle(
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
