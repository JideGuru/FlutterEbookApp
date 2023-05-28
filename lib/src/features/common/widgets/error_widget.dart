import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  final Function refreshCallBack;
  final bool isConnection;

  const MyErrorWidget({
    super.key,
    required this.refreshCallBack,
    this.isConnection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            '😔',
            style: TextStyle(
              fontSize: 60.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              getErrorText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge!.color,
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => refreshCallBack(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text(
              'TRY AGAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getErrorText() {
    if (isConnection) {
      return 'There is a problem with your internet connection. '
          '\nPlease try again.';
    } else {
      return 'Could not load this page. \nPlease try again.';
    }
  }
}
