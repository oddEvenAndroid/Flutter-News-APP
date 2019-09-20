import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_news_web/model/news.dart';
import 'package:flutter_news_web/news_details.dart';
import 'package:http/http.dart' as http;

class NewsListPage extends StatefulWidget {
  final String title;
  final String newsType;

  NewsListPage(this.title, this.newsType);

  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  @override
  void initState() {
    super.initState();
  }

  /**
   * 
   * API Call and get  data
   * 
   */

  Future<List<Article>> getData(String newsType) async {
    List<Article> list;
    String link;
    if (newsType == "top_news") {
      link =
          "https://newsapi.org/v2/top-headlines?country=in&apiKey=bf32beee9bad47288d57af7c8ec0e967";
    } else {
      link =
          "https://newsapi.org/v2/top-headlines?country=in&category=$newsType&apiKey=bf32beee9bad47288d57af7c8ec0e967";
    }
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    // print(res.body);
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var status = data["status"];
      var rest = data["articles"] as List;
      print(rest);
      list = rest.map<Article>((json) => Article.fromJson(json)).toList();
    }
    print("List Size: ${list.length}");
    return list;
  }

  /**
   * 
   * Create Custom Widget For List
   * 
   */

  Widget listViewWidget(List<Article> article) {
    return Container(
      child: ListView.builder(
          itemCount: article.length,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (context, position) {
            return Card(
              child: Container(
                height: 120.0,
                width: 120.0,
                child: Center(
                  child: ListTile(
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        '${article[position].author}',
                      ),
                    ),
                    title: Text(
                      '${article[position].title}',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      height: 100.0,
                      width: 100.0,
                      child: article[position].urlToImage == null
                          ? Image.asset(
                              'images/no_image_available.png',
                              height: 70,
                              width: 70,
                            )
                          : Image.network(
                              '${article[position].urlToImage}',
                              height: 70,
                              width: 70,
                            ),
                    ),
                    onTap: () => _onTapItem(context, article[position]),
                  ),
                ),
              ),
            );
          }),
    );
  }

/**
   * 
   * Create Method for Click event of Item
   * 
   */
  void _onTapItem(BuildContext context, Article article) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => NewsDetails(article, widget.title)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: getData(widget.newsType),
          builder: (context, snapshot) {
            return snapshot.data != null
                ? listViewWidget(snapshot.data)
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}
