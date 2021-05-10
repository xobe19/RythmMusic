import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.blue),
          child: ListTile(
              leading: FaIcon(FontAwesomeIcons.facebookF),
              title: Text(
                'Continue with Facebook',
                style: TextStyle(color: Colors.white),
              ))),
    );
  }
}
