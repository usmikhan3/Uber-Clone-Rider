import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider/assistants/size_config.dart';
import 'package:uber_rider/main.dart';
import 'package:uber_rider/screens/mainScreen.dart';
import '../widgets/progressIndicator.dart';
import 'loginScreen.dart';

class RegisterScreen extends StatelessWidget {
  static const idScreen = "register";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  void registerNewUser(BuildContext context) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Creating User...please wait");
        }
    );


    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      //TODO: SAVE DATA TO DATABASE

      Map userDataMap = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
      };

      usersRef.child(firebaseUser.uid).set(userDataMap);
      displayToast("Congratulations! Your account has been created", context);
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);

    } else {
      //TODO: ERROR OCCURRED
      Navigator.pop(context);
      displayToast("new user is not created", context);
    }
  }

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
                  height: 51.8134715 * SizeConfig.heightMultiplier, //400,
                  width: 69.444444  * SizeConfig.widthMultiplier, //250
                ),
              ),
              //TODO: LOGIN TEXT
              Text(
                "Register as a rider",
                style: TextStyle(fontSize: 2.59067357 * SizeConfig.textMultiplier /*20*/, fontFamily: "Brand Bold"),
              ),

              //TODO: FORM FIELD

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                          hintText: "Enter your name",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 1.29533678 * SizeConfig.textMultiplier /*10.0*/)),
                      style: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                          hintText: "Enter your Email Address",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 1.29533678 * SizeConfig.textMultiplier /*10.0*/)),
                      style: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                    ),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: "Phone",
                          labelStyle: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                          hintText: "Enter your phone Number",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize:  1.29533678 * SizeConfig.textMultiplier /*10.0*/)),
                      style: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                          hintText: "Enter your Password",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize:  1.29533678 * SizeConfig.textMultiplier /*10.0*/)),
                      style: TextStyle(fontSize: 1.81347150 * SizeConfig.textMultiplier /*14.0*/),
                    ),
                    SizedBox(
                      height:  1.29533678 * SizeConfig.heightMultiplier /*10.0*/,
                    ),
                    RaisedButton(
                      color: Colors.yellow,
                      textColor: Colors.black,
                      child: Container(
                        height: 6.4766839 * SizeConfig.heightMultiplier  /*50.0*/,
                        child: Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                                fontSize: 14.0, fontFamily: "Bramd Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      onPressed: () {
                        if (nameController.text.length < 3) {
                          displayToast(
                              "name must be atleast 10 characters", context);
                        } else if (!emailController.text.contains("@")) {
                          displayToast("email address is not valid", context);
                        } else if (phoneController.text.isEmpty) {
                          displayToast("Phone number is mandatory", context);
                        } else if (passwordController.text.length < 4) {
                          displayToast("password must be atleast 10 characters",
                              context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                    )
                  ],
                ),
              ),

              FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: Text("Already have an account? Login here"))
            ],
          ),
        ),
      ),
    );
  }
}
