import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_kitty/epub_kitty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebook_app/database/download_helper.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:uuid/uuid.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  static const pageChannel = const EventChannel('com.xiaofwang.epub_kitty/page');

  bool done = true;
  var db = DownloadsDB();
  static final uuid = Uuid();

  List dls = List();
  getDownloads() async{
    List l = await db.listAll();
    setState(() {
      dls.addAll(l);
    });
  }

  @override
  void initState() {
    super.initState();
    getDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Downloads"),
      ),
      body: dls.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "assets/images/empty.png",
              height: 300,
              width: 300,
            ),

            Text(
              "Nothing is here",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15),
        shrinkWrap: true,
        itemCount: dls.length,
        itemBuilder: (BuildContext context, int index) {
          Map dl = dls[index];

          return Dismissible(
            key: ObjectKey(uuid.v4()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: Icon(
                Feather.trash_2,
                color: Colors.white,
              ),
            ),
            onDismissed: (d) async{
              db.remove({"id": dl['id']}).then((v) async{
                File f = File(dl['path']);
                if(await f.exists()){
                  f.delete();
                }
                setState(() {
                  dls.removeAt(index);
                });
                print("done");
              });
            },
            child: InkWell(
              onTap: (){
                String path = dl['path'];
                EpubKitty.setConfig("androidBook", "#06d6a7","vertical",true);
                EpubKitty.open(path);

                pageChannel.receiveBroadcastStream().listen((Object event) {
                  print('page:$event');
                }, onError: null);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: dl['image'],
                      placeholder: (context, url) => Container(
                        height: 70,
                        width: 70,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/place.png",
                        fit: BoxFit.cover,
                        height: 70,
                        width: 70,
                      ),
                      fit: BoxFit.cover,
                      height: 70,
                      width: 70,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Flexible(
                      child: done
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            dl['name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "COMPLETED",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                dl['size'],
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Alice's Adventures in Wonderland",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                           height: 5,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: 0.7,
                              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
                              backgroundColor: Theme.of(context).accentColor.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "70%",
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                "300kb of 415kb",
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }
}
