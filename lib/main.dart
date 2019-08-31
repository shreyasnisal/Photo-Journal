import 'package:flutter/material.dart';
import './firebase/Mapping.dart';
import './firebase/Authentication.dart';

void main() {
  runApp(new PhotoJournal());
}

class PhotoJournal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Photo Journal",

      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ), //ThemeData

      home: MappingPage(auth: Auth()),
    ); //MaterialApp
  }
}
