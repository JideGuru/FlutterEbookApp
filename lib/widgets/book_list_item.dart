import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/screen/details.dart';
import 'package:flutter_ebook_app/widgets/summary_text.dart';
import 'package:page_transition/page_transition.dart';

class BookListItem extends StatelessWidget {
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
      child: Container(
        height: 150,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: Image.asset(
                  "assets/images/1.jpg",
                  fit: BoxFit.cover,
                  height: 150,
                  width: 100,
                ),
              ),
            ),

            SizedBox(width: 10,),

            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Le Debut des Haricots",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    "Jane Austen",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  ),

                  SummaryTextWidget(
                    text: "<p>This Edwardian social comedy explores love and prim propriety among an eccentric cast of characters assembled in an Italian pensione and in a corner of Surrey, England.</p> <p>A charming young Englishwoman, Lucy Honeychurch, faints into the arms of a fellow Britisher when she witnesses a murder in a Florentine piazza. Attracted to this man, George Emerson&#8212;who is entirely unsuitable and whose father just may be a Socialist&#8212;Lucy is soon at war with the snobbery of her class and her own conflicting desires. Back in England, she is courted by a more acceptable, if stifling, suitor and soon realizes she must make a startling decision that will decide the course of her future: she is forced to choose between convention and passion. </p>",
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
