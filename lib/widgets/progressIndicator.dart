import 'package:flutter/material.dart';
import 'package:uber_rider/assistants/size_config.dart';

class ProgressDialog extends StatelessWidget {


  String message;
  ProgressDialog({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.yellow,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),

              FittedBox(child: Text(message, style: TextStyle(color: Colors.black, fontSize: 1.55440414 * SizeConfig.textMultiplier /*12*/),))
            ],
          ),
        ),
      ),
    );
  }
}
