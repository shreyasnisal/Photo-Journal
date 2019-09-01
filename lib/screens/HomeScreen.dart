import 'package:flutter/material.dart';
import 'UploadPhotoScreen.dart';
import '../classes/Posts.dart';
import '../firebase/Authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({
    this.auth,
    this.onSignedOut
  });

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {

  List<Posts> postsList = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    getPosts();
  }

  void getPosts() {

    setState(() {
      _loading = true;
    });

    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Posts");

    postsList.clear();

    postsRef.once().then((DataSnapshot snap) {

      if (snap.value == null)
        setState(() {
          _loading = false;
        });

      else {

        var KEYS = snap.value.keys;
        var DATA = snap.value;

        postsList.clear();

        for(var individualKey in KEYS) {
          Posts posts = new Posts(
            DATA[individualKey]['timestamp'],
            individualKey.toString(),
            DATA[individualKey]['image'],
            DATA[individualKey]['caption'],
            DATA[individualKey]['date'],
            DATA[individualKey]['time'],
          );

          postsList.add(posts);
        }

        sortByTimestamp(postsList);

        setState(() {
          _loading = false;
        });
      }
    });
  }

  void sortByTimestamp(List<Posts> postsList) {
    for (int i = 0; i < postsList.length; i++) {
      for (int j = 0; j < postsList.length; j++) {
        if (postsList[i].timestamp.compareTo(postsList[j].timestamp) > 0) {
          Posts temp = postsList[i];
          postsList[i] = postsList[j];
          postsList[j] = temp;
        }
      }
    }
  }

  void goToUploadPhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return new UploadPhotoScreen();
      }), //MaterialPageRoute
    ).then((value) {
      getPosts();
      setState(() {});
    }); //Navigator
  }

  void deletePost(String key, String imageUrl) {
    setState(() {
      _loading = true;
    });
    DatabaseReference postRef = FirebaseDatabase.instance.reference().child("Posts").child(key);
    postRef.remove().then((value) {

      StorageReference photoStorageRef = FirebaseStorage.instance.ref().child("Uploaded Images").child(imageUrl + ".jpg");
      photoStorageRef.delete().then((value) {
        getPosts();
      });
    });
  }

  //Design
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text("Home"),
      ), //AppBar

      body: _loading ? Center(child: CircularProgressIndicator())
        : new Container(
        child: postsList.length == 0
        ? Center(
          child: new Text(
            "No photos uploaded",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ), //TextStyle
          ) //Text
        ) //Center
        : new ListView.builder(
          itemCount: postsList.length,
          itemBuilder: (_, index) {
            return PostsUI(postsList[index].timestamp, postsList[index].key, postsList[index].image, postsList[index].caption, postsList[index].date, postsList[index].time);
          }
        ), //ListView.builder
      ), //Container

      floatingActionButton: new FloatingActionButton(
        onPressed: goToUploadPhoto,
        tooltip: 'Add Image',
        child: new Icon(Icons.add_a_photo),
      ), //FloatingActionButton
    );
  }

  Widget PostsUI(String timestamp, String key, String image, String caption, String date, String time) {
    return new Card(
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),

      child: new Container(
        padding: new EdgeInsets.all(14.0),

        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: <Widget>[
                new Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,
                ), //Text

                new Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,
                ), //Text
              ], //Widget
            ), //Row

            SizedBox(height: 10.0),

            // new Image.network(image, fit: BoxFit.cover),
            Center(
              child: FadeInImage.assetNetwork(
                placeholder: 'images/placeholder.gif',
                image: image,
                fit: BoxFit.cover,
              ), //FadeInImage
            ), //Center

            SizedBox(height: 10.0),

            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  caption,
                  style: Theme.of(context).textTheme.subhead,
                  textAlign: TextAlign.center
                ), //Text
                IconButton(
                  icon: Icon(Icons.delete),
                  // color: Colors.red,
                  onPressed: () {
                    deletePost(key, timestamp);
                  },
                ), //IconButton
              ], //<Widget>
            ), //Row
          ], //<Widget>
        ), //Column
      ), //Container
    ); //Card
  }
}
