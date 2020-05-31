import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_ebook_app/components/book_card.dart';
import 'package:flutter_ebook_app/components/book_list_item.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_ebook_app/views/genre.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => Provider.of<HomeProvider>(context, listen: false).getFeeds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider homeProvider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "${Constants.appName}",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          body: homeProvider.loading
              ? _buildProgressIndicator()
              : _buildBodyList(homeProvider),
        );
      },
    );
  }

  _buildBodyList(HomeProvider homeProvider) {
    return RefreshIndicator(
      onRefresh: () => homeProvider.getFeeds(),
      child: ListView(
        children: <Widget>[
          _buildFeaturedSection(homeProvider),
          SizedBox(height: 20),
          _buildSectionTitle("Categories"),
          SizedBox(height: 10),
          _buildGenreSection(homeProvider),
          SizedBox(height: 20),
          _buildSectionTitle("Recently Added"),
          SizedBox(height: 20),
          _buildNewSection(homeProvider),
        ],
      ),
    );
  }

  _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$title",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildFeaturedSection(HomeProvider homeProvider) {
    return Container(
      height: 200,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          itemCount: homeProvider.top.feed.entry.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Entry entry = homeProvider.top.feed.entry[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: BookCard(
                img: entry.link[1].href,
                entry: entry,
              ),
            );
          },
        ),
      ),
    );
  }

  _buildGenreSection(HomeProvider homeProvider) {
    return Container(
      height: 50,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          itemCount: homeProvider.top.feed.link.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Link link = homeProvider.top.feed.link[index];

            // We don't need the tags from 0-9 because
            // they are not categories
            if (index < 10) {
              return SizedBox();
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: Genre(
                          title: "${link.title}",
                          url: Api.baseURL + link.href,
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "${link.title}",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildNewSection(HomeProvider homeProvider) {
    return ListView.builder(
      primary: false,
      padding: EdgeInsets.symmetric(horizontal: 15),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: homeProvider.recent.feed.entry.length,
      itemBuilder: (BuildContext context, int index) {
        Entry entry = homeProvider.recent.feed.entry[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: BookListItem(
            img: entry.link[1].href,
            title: entry.title.t,
            author: entry.author.name.t,
            desc: entry.summary.t,
            entry: entry,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
