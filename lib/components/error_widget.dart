import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  final void Function() refreshCallBack;
  final bool isConnection;

  MyErrorWidget({@required this.refreshCallBack, this.isConnection = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 30.0, right: 20.0, left: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "😔",
            style: TextStyle(
              fontSize: 60,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              getErrorText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.title.color,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            child: RaisedButton(
              onPressed: refreshCallBack,
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "RETRY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 0.875,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getErrorText() {
    if(isConnection){
      return "There is a problem with your internet connection. \nPlease try again.";
    }else{
      return "Something went wrong. \nPlease try again.";
    }
  }
}
