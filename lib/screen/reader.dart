import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';

class Reader extends StatelessWidget {
  final String path;

  Reader({
    Key key,
    @required this.path
  }):super(key: key);

  Future<Uint8List> _loadFromStorage() async {
    print(path);
    return await File(path).readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EpubBook>(
        future: _loadFromStorage().then(EpubReader.readBook),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return EpubReaderView(
              book: snapshot.data,
              // Called when scrolled to another chapter
              headerBuilder: (value) => AppBar(
                title: Text(
                  '${value?.chapter?.Title ?? 'Loading...'}',
                ),
              ),
              // Start from special chapter
//              startFrom: EpubReaderLastPosition(3),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
