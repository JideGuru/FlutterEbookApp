import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_kitty/epub_kitty.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/view_models/details_provider.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_ebook_app/components/book_list_item.dart';
import 'package:flutter_ebook_app/components/description_text.dart';
import 'package:flutter_ebook_app/components/download_alert.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


// ignore: must_be_immutable
class Details extends StatelessWidget {
  final Entry entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  Details({
    Key key,
    @required this.entry,
    @required this.imgTag,
    @required this.titleTag,
    @required this.authorTag,
  }): super(key:key);
  static const pageChannel = const EventChannel('com.xiaofwang.epub_kitty/page');

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsProvider>(
      builder: (BuildContext context, DetailsProvider detailsProvider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () async{
                  if(detailsProvider.faved){
                    detailsProvider.removeFav();
                  }else{
                    detailsProvider.addFav();
                  }
                },
                icon: Icon(
                  detailsProvider.faved
                      ? Icons.favorite
                      : Feather.heart,
                  color: detailsProvider.faved
                      ? Colors.red
                      : Theme.of(context).iconTheme.color,
                ),
              ),

              IconButton(
                onPressed: (){
                  Share.text(
                    "${entry.title.t} by ${entry.author.name.t}",
                    "Read/Download ${entry.title.t} from ${entry.link[3].href}.",
                    "text/plain",
                  );
                },
                icon: Icon(
                  Feather.share,
                ),
              ),
            ],
          ),

          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              SizedBox(height: 10,),

              Container(
                height: 200,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: imgTag,
                      child: CachedNetworkImage(
                        imageUrl: "${entry.link[1].href}",
                        placeholder: (context, url) => Container(
                          height: 200,
                          width: 130,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Feather.x),
                        fit: BoxFit.cover,
                        height: 200,
                        width: 130,
                      ),
                    ),

                    SizedBox(width: 20,),

                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 5,),
                          Hero(
                            tag: titleTag,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                "${entry.title.t.replaceAll(r"\", "")}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Hero(
                            tag: authorTag,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                "${entry.author.name.t}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 5,),

                          entry.category == null?SizedBox():Container(
                            height: entry.category.length<3?40:80,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: entry.category.length>4?4:entry.category.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 210/80,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                Category cat = entry.category[index];
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).backgroundColor,
                                      borderRadius: BorderRadius.all(Radius.circular(20),),
                                      border: Border.all(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 2),
                                        child: Text(
                                          "${cat.label}",
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                            fontSize: cat.label.length >18 ? 6:10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),


                          Center(
                            child: Container(
                              height: 20,
                              width: MediaQuery.of(context).size.width,
                              child: detailsProvider.downloaded
                                  ?  FlatButton(
                                onPressed: (){
                                  detailsProvider.getDownload().then((c){
                                    if(c.isNotEmpty){
                                      Map dl = c[0];
                                      String path = dl['path'];
                                      EpubKitty.setConfig("androidBook", "#06d6a7","vertical",true);
                                      EpubKitty.open(path);

                                      pageChannel.receiveBroadcastStream().listen((Object event) {
                                        print('page:$event');
                                      }, onError: null);
                                    }
                                  });
                                },
                                child: Text(
                                  "Read Book",
                                ),
                              )
                                  : FlatButton(
                                onPressed: ()=>downloadFile(
                                  context,
                                  entry.link[3].href,
                                  entry.title.t
                                      .replaceAll(" ", "_")
                                      .replaceAll(r"\'", ""),
                                ),
                                child: Text(
                                  "Download",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: 30,),

              Text(
                "Book Description",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Theme.of(context).textTheme.caption.color,),
              SizedBox(height: 10,),

              DescriptionTextWidget(
                text: "${entry.summary.t}",
              ),

              SizedBox(height: 30,),

              Text(
                "More from Author",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Theme.of(context).textTheme.caption.color,),

              SizedBox(height: 10,),

              detailsProvider.loading
                  ? Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: detailsProvider.related.feed.entry.length,
                itemBuilder: (BuildContext context, int index) {
                  Entry entry = detailsProvider.related.feed.entry[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: BookListItem(
                      img: entry.link[1].href,
                      title: entry.title.t,
                      author: entry.author.name.t,
                      desc: entry.summary.t,
                      entry: entry,
                    ),
                  );
                },
              ),
            ],
          ),

        );
      },
    );
  }

  Future downloadFile(BuildContext context, String url, String filename) async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    if(permission != PermissionStatus.granted){
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      startDownload(context, url, filename);
    }else{
      startDownload(context, url, filename);
    }
  }

  startDownload(BuildContext context, String url, String filename) async{
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    if(Platform.isAndroid){
      Directory(appDocDir.path.split("Android")[0]+"${Constants.appName}").create();
    }

    String path = Platform.isIOS
        ? appDocDir.path+"/$filename.epub"
        : appDocDir.path.split("Android")[0]+"${Constants.appName}/$filename.epub";
    print(path);
    File file = File(path);
    if(!await file.exists()){
      await file.create();
    }else{
      await file.delete();
      await file.create();
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        path: path,
      ),
    ).then((v){
      if(v != null){
        Provider.of<DetailsProvider>(context, listen: false).addDownload(
          {
            "id": entry.published.t,
            "path": path,
            "image": "${entry.link[1].href}",
            "size": v,
            "name": entry.title.t,
          },
        );
      }
    });
  }
}
