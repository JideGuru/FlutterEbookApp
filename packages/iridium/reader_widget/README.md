Plug and play reader widget allowing to easily integrate an Iridium viewer inside any app.

## Features

- Display Epub e-books.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

The `example` suidirectory provides a minimalistic starting point.

Add the iridium_reader_widget project as a submodule and add it to the dependencies list (it is not published on Pub.dev yet).

In the Flutter screen where you want to embed a vieser:

```dart
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
```

And anywhere in your view hierarchy:

```dart
EpubScreen.fromPath(filePath: widget.dirPath)
```

## Additional information

More information [here](https://github.com/Mantano/Iridium) and [here](https://iridium.rocks).