import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/widgets/book_list_item.dart';
import 'package:flutter_ebook_app/widgets/description_text.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: Icon(
              Feather.download,
            ),
          ),

          IconButton(
            onPressed: (){},
            icon: Icon(
              Feather.heart,
            ),
          ),

          IconButton(
            onPressed: (){},
            icon: Icon(
              Feather.share_2,
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
                Image.asset(
                  "assets/images/1.jpg",
                  fit: BoxFit.cover,
                  height: 200,
                  width: 130,
                ),

                SizedBox(width: 20,),

                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 5,),
                      Text(
                        "Le Debut des Haricots",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Jane Austen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 5,),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 210/100,
                        ),
                        itemBuilder: (BuildContext context, int index) {
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
                                    "Romance",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 5,),

                      Center(
                        child: FlatButton(
                          onPressed: (){},
                          child: Text(
                            "Read book",
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

          SizedBox(height: 10,),

          DescriptionTextWidget(
            text: "<p>This Edwardian social comedy explores love and prim propriety among an eccentric cast of characters assembled in an Italian pensione and in a corner of Surrey, England.</p> <p>A charming young Englishwoman, Lucy Honeychurch, faints into the arms of a fellow Britisher when she witnesses a murder in a Florentine piazza. Attracted to this man, George Emerson&#8212;who is entirely unsuitable and whose father just may be a Socialist&#8212;Lucy is soon at war with the snobbery of her class and her own conflicting desires. Back in England, she is courted by a more acceptable, if stifling, suitor and soon realizes she must make a startling decision that will decide the course of her future: she is forced to choose between convention and passion. </p>",
          ),

          SizedBox(height: 30,),

          Text(
            "Related Books",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10,),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: BookListItem(),
              );
            },
          ),
        ],
      ),

    );
  }
}
