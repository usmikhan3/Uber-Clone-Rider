import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_rider/screens/loginScreen.dart';
import 'package:uber_rider/screens/mainScreen.dart';
import 'package:uber_rider/screens/registerScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber Rider',
      theme: ThemeData(
        fontFamily: "Brand Bold",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: MainScreen.idScreen,
      routes: {
        RegisterScreen.idScreen : (_)=>RegisterScreen(),
        LoginScreen.idScreen : (_)=>LoginScreen(),
        MainScreen.idScreen : (_)=>MainScreen(),
      },
    );
  }
}

