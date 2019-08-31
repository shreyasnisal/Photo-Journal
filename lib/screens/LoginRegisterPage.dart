import 'package:flutter/material.dart';
import '../firebase/Authentication.dart';
import '../components/DialogBox.dart';

class LoginRegisterPage extends StatefulWidget {

  LoginRegisterPage({
    this.auth,
    this.onSignedIn,
  });

  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  State<StatefulWidget> createState() {
    return _LoginRegisterState();
  }
}

enum FormType {login, register}

class _LoginRegisterState extends State<LoginRegisterPage> {

  DialogBox dialogBox = new DialogBox();

  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";

  //Methods
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.signIn(_email, _password);
          print("login userId = " + userId);
        }
        else {
          String userId = await widget.auth.signUp(_email, _password);
          print("Created userId = " + userId);
        }

        widget.onSignedIn();
      }
      catch(e) {
        dialogBox.information(context, "Failed", "Login/Signup failed. Please check your internet and login credentials");
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }

  //Design
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Photo Journal"),
      ), //AppBar

      body: new Container(
        margin: EdgeInsets.all(15.0),

        child: new Form(
          key: formKey,
          child: new ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createInputs() + createButtons()
          ), //Column
        ), //Form
      ), //Container
    ); //Scaffold
  }

  List<Widget> createInputs() {
    return[
      SizedBox(height: 10.0),
      logo(),
      SizedBox(height: 20.0),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Email'),

        validator: (value) {
          return value.isEmpty ? 'Please enter email' : null;
        },

        onSaved: (value) {
          return _email = value;
        },
      ), //TextFormField

      SizedBox(height: 10.0),

      new TextFormField(
        decoration: new InputDecoration(labelText: 'Password'),
        obscureText: true,

        validator: (value) {
          return value.isEmpty ? 'Please enter password' : null;
        },

        onSaved: (value) {
          return _password = value;
        },
      ), //TextFormField

      SizedBox(height: 20.0),
    ];
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return[
        new RaisedButton(
          child: new Text("Login", style: new TextStyle(fontSize: 24.0)),
          textColor: Colors.white,
          // color: Colors.purple,

          onPressed: validateAndSubmit,
        ), //RaisedButton
        new FlatButton(
          child: new Text("Create Account", style: new TextStyle(fontSize: 20.0)),
          // textColor: Colors.purple,

          onPressed: moveToRegister,
        ), //FlatButton
      ];
    }
    else {
      return[
        new RaisedButton(
          child: new Text("Sign Up", style: new TextStyle(fontSize: 24.0)),
          textColor: Colors.white,
          // color: Colors.purple,

          onPressed: validateAndSubmit,
        ), //RaisedButton
        new FlatButton(
          child: new Text("Already have an account?", style: new TextStyle(fontSize: 20.0)),
          // textColor: Colors.purple,

          onPressed: moveToLogin,
        ), //FlatButton
      ];
    }
  }

  Widget logo() {
    return new Hero(
      tag: 'hero',

      child: new CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: Image.asset('images/logo.png'),
      ),
    );
  }
}
