import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/enum/api_request_status.dart';
import 'package:flutter_ebook_app/util/functions.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GenreProvider extends ChangeNotifier {
  ScrollController controller = ScrollController();
  List items = List();
  int page = 1;
  bool loadingMore = false;
  bool loadMore = true;
  APIRequestStatus apiRequestStatus = APIRequestStatus.loading;

  listener(url) {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (!loadingMore) {
          paginate(url);
          // Animate to bottom of list
          Timer(Duration(milliseconds: 100), () {
            controller.animateTo(
              controller.position.maxScrollExtent,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeIn,
            );
          });
        }
      }
    });
  }

  getFeed(String url) {
    setApiRequestStatus(APIRequestStatus.loading);
    print(url);
    Api.getCategory(url).then((feed) {
      items = feed.feed.entry;
      setApiRequestStatus(APIRequestStatus.loaded);
      listener(url);
    }).catchError((e) {
      checkError(e);
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
      );
      throw (e);
    });
  }

  paginate(String url) {
    if (apiRequestStatus != APIRequestStatus.loading &&
        !loadingMore &&
        loadMore) {
      Timer(Duration(milliseconds: 100), () {
        controller.jumpTo(controller.position.maxScrollExtent);
      });
      loadingMore = true;
      page = page + 1;
      notifyListeners();
      Api.getCategory(url + '&page=$page').then((feed) {
        items.addAll(feed.feed.entry);
        loadingMore = false;
        notifyListeners();
      }).catchError((e) {
        loadMore = false;
        loadingMore = false;
        notifyListeners();
        throw (e);
      });
    }
  }

  void checkError(e) {
    if (Functions.checkConnectionError(e)) {
      setApiRequestStatus(APIRequestStatus.connectionError);
    } else {
      setApiRequestStatus(APIRequestStatus.error);
    }
  }

  void setApiRequestStatus(APIRequestStatus value) {
    apiRequestStatus = value;
    notifyListeners();
  }
}
