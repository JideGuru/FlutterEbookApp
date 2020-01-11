import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/screen/details.dart';
import 'package:page_transition/page_transition.dart';

class BookItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Details(),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            child: Image.asset(
              "assets/images/1.jpg",
              fit: BoxFit.cover,
              height: 150,
            ),
          ),

          SizedBox(height: 5,),

          Text(
            "Ann of Green Gables",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
