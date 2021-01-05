import 'package:flutter/material.dart';
import 'package:uber_rider/assistants/size_config.dart';

class DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.129533678 * SizeConfig.heightMultiplier,
      color: Colors.black45,
      thickness: 0.129533678 * SizeConfig.heightMultiplier,
    );
  }
}
