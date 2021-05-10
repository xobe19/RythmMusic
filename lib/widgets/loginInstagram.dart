import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InstagramLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.pinkAccent])),
          child: ListTile(
              leading: FaIcon(FontAwesomeIcons.phone),
              title: Text(
                'Continue with Phone',
                style: TextStyle(color: Colors.white),
              ))),
    );
  }
}
