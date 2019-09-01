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
  DateTime _date = DateTime.now(), _time = DateTime.now();
  String url;
  bool _loading = true;
  var timeKey;

  var formatDate = new DateFormat('MMM d, yyyy');
  var formatTime = new DateFormat('hh:mm aa');

  var selectedDate;
  var selectedTime;

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    selectedDate = formatDate.format(DateTime.now());
    selectedTime = formatTime.format(DateTime.now());

    getImage();

  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (tempImage == null) Navigator.pop(context);

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
      // timeKey = new DateTime.now();
      timeKey = new DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute).toString();

      final StorageUploadTask uploadTask = firebaseStorageRef.child(timeKey.toString() + ".jpg").putFile(uploadImage);

      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = imageUrl.toString();

      goToHomeScreen();
      saveToDatabase(url);
    }
  }

  void saveToDatabase(url) {
    // var dbTimeKey = new DateTime.now();
    // var dbTimeKey = timeKey;

    // String date = formatDate.format(dbTimeKey);
    // String time = formatTime.format(dbTimeKey);

    DatabaseReference firebaseDbRef = FirebaseDatabase.instance.reference();

    var data = {
      "timestamp": timeKey.toString(),
      "image": url,
      "caption": _caption,
      "date": selectedDate,
      "time": selectedTime,
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
          : uploadImage == null
          ? Container()
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

            Row(
              children: <Widget>[
                Text(selectedDate),
                IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2018),
                      lastDate: DateTime.now(),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light(),
                          child: child,
                        ); //Theme
                      },
                    ).then((date) {
                      _date = date;
                      selectedDate = formatDate.format(date);
                      setState(() {});
                    }); //showDatePicker
                  }
                ), //IconButton

                Text(selectedTime),
                IconButton(
                  icon: Icon(Icons.watch_later),
                  onPressed: () {
                    showTimePicker(
                      initialTime: TimeOfDay.now(),
                      context: context,
                    ).then((t) {
                      var now = DateTime.now();
                      _time = DateTime(now.day, now.month, now.year).add(Duration(hours: t.hour, minutes: t.minute));
                      selectedTime = formatTime.format(_time);
                      setState(() {});
                    }); //showTimePicker
                  }
                ), //IconButton
              ], //<Widget>
            ), //Row

            SizedBox(height: 15.0),

            TextFormField(
              decoration: new InputDecoration(labelText: 'Caption'),

              validator: (value) {
                return value.isEmpty ? 'Please enter a caption' : null;
              },

              onSaved: (value) {
                return _caption = value;
              },
            ), //TextFormField

            SizedBox(height: 15.0),

            RaisedButton(
              elevation: 10.0,

              child: Text("Upload"),
              textColor: Colors.white,
              color: Colors.blue,

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
