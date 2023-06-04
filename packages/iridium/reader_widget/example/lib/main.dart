import 'package:example/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:mno_webview/webview.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:universal_io/io.dart' hide Link;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    Fimber.plantTree(FimberTree());
  } else {
    Fimber.plantTree(DebugBufferTree());
  }
  if (kDebugMode && Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  var fileName = "assets/books/accessible_epub_3.epub";
  // var fileName = "assets/books/39419251_rtl.epub";
  // var fileName = "assets/books/9782067179578_GM_PARIS_2012_ANDROID.epub";
  // var fileName = "assets/books/Code du travail.epub";
  var dirPath = (await Utils.getFileFromAsset(fileName)).path;
  runApp(MyApp(dirPath));
}

class MyApp extends StatelessWidget {
  final String dirPath;

  const MyApp(this.dirPath, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Iridium Widget Demo', dirPath: dirPath),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.dirPath});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String dirPath;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: EpubScreen.fromPath(
          filePath: widget.dirPath,
          location: '{"cfi":" ","idref":"file_12.html"}',
          paginationCallback: (paginationInfo) {
            Fimber.d("--- paginationInfo: $paginationInfo");
          },
        ), //'{"idref":"id-id2640702"}'
      ),
    );
  }
}
