import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'HomeScreen.dart';

class UploadPhotoScreen extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _UploadPhotoScreenState();
  }
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {

  File uploadImage;
  String _caption;
  var _date, _time;
  String url;
  bool _loading = true;
  var timeKey;

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    getImage();
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      uploadImage = tempImage;
    });

    setState(() {
      _loading = false;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    else {
      return false;
    }
  }

  void doUploadImage() async {

    if (validateAndSave()) {
      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("Uploaded Images");
      timeKey = new DateTime.now();

      final StorageUploadTask uploadTask = firebaseStorageRef.child(timeKey.toString() + ".jpg").putFile(uploadImage);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = imageUrl.toString();

      goToHomeScreen();
      saveToDatabase(url);
    }
  }

  void saveToDatabase(url) {
    // var dbTimeKey = new DateTime.now();
    var dbTimeKey = timeKey;
    var formatDate = new DateFormat('MMM d, yyyy');
    var formatTime = new DateFormat('EEEE, hh:mm aa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference firebaseDbRef = FirebaseDatabase.instance.reference();

    var data = {
      "timestamp": dbTimeKey.toString(),
      "image": url,
      "caption": _caption,
      "date": date,
      "time": time,
    };

    firebaseDbRef.child("Posts").push().set(data);
  }

  void goToHomeScreen() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return new HomeScreen();
    //   }), //MaterialPageRoute
    // ); //Navigator
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Upload Photo"),
        centerTitle: true,
      ), //AppBar

      body: new Center(
        child: _loading
          ? CircularProgressIndicator()
          : enableUpload(),
      ), //Center


    ); //Scaffold
  }

  Widget enableUpload() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: new Form(
        key: formKey,

        child: ListView(
          children: <Widget>[
            Image.file(uploadImage, height: 330.0, width: 660.0),

            SizedBox(height:15.0),

            TextFormField(
              decoration: new InputDecoration(labelText: 'Caption'),

              validator: (value) {
                return value.isEmpty ? 'Please enter a caption' : null;
              },

              onSaved: (value) {
                return _caption = value;
              },
            ), //TextFormField

            SizedBox(height:15.0),

            RaisedButton(
              elevation: 10.0,

              child: Text("Upload"),
              textColor: Colors.white,
              // color: Colors.purple,

              onPressed: () {
                setState(() {
                  _loading = true;
                  doUploadImage();
                });
              },
            ), //RaisedButton
          ], //<Widget>
        ), //Column
      ), //Form
    ); //Container
  }
}
