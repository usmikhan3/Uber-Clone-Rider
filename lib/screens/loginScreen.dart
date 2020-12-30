import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_rider/screens/registerScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider/main.dart';
import 'package:uber_rider/screens/mainScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/progressIndicator.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginUser(BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressDialog(message: "Authenticating! please wait");
      }
    );

    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((errMsg) {
              Navigator.pop(context);
      displayToast("Error: " + errMsg.toString(), context);
    }))
        .user;
    if (firebaseUser != null) {
      //TODO: SAVE DATA TO DATABASE

      usersRef
          .child(firebaseUser.uid)
          .once()
          .then((DataSnapshot snap) {
                if (snap.value != null) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.idScreen, (route) => false);
                  displayToast(
                      "Congratulations! Your are logged in now", context);
                } else {
                  Navigator.pop(context);
                  _firebaseAuth.signOut();
                  displayToast(
                      "no user found..please register yourself first", context);
                }
              });
    } else {
      //TODO: ERROR OCCURRED
      Navigator.pop(context);
      displayToast("Error Occurred.. try again", context);
    }
  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  static const idScreen = "login";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //TODO: LOGO IMAGE
              Center(
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  height: 400,
                  width: 250,
                ),
              ),

              //TODO: LOGIN TEXT
              Text(
                "Login as a rider",
                style: TextStyle(fontSize: 20, fontFamily: "Brand Bold"),
              ),

              //TODO: FORM FIELD

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintText: "Enter your Email Address",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintText: "Enter your Password",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      color: Colors.yellow,
                      textColor: Colors.black,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 14.0, fontFamily: "Bramd Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      onPressed: () {
                        if (!emailController.text.contains("@")) {
                          displayToast("email address is not valid", context);
                        }
                        else if (passwordController.text.isEmpty) {
                          displayToast("password is mandatory",
                              context);
                        }
                        else{
                          loginUser(context);
                        }

                      },
                    )
                  ],
                ),
              ),

              FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegisterScreen.idScreen, (route) => false);
                  },
                  child: Text("Do not have account? Register here"))
            ],
          ),
        ),
      ),
    );
  }
}
