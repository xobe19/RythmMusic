import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.redAccent),
          child: ListTile(
              leading: FaIcon(FontAwesomeIcons.google),
              title: Text(
                'Continue with Google',
                style: TextStyle(color: Colors.white),
              ))),
    );
  }
}
