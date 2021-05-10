import 'package:flutter/material.dart';
import '../widgets/loginGoogleButton.dart';
import '../widgets/loginFacebook.dart';
import '../widgets/loginInstagram.dart';
import '../widgets/loginEmail.dart';
import '../widgets/logoBar.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(flex: 2, child: Hero(tag: "bar", child: LogoBar())),
            Expanded(
                flex: 3,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                                child: GoogleLoginButton(),
                                onTap: () {
                                  Navigator.pushNamed(context, '/googleSignUp');
                                }),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/facebookSignUp');
                                },
                                child: FacebookLoginButton()),
                            GestureDetector(
                                child: InstagramLoginButton(),
                                onTap: () {
                                  Navigator.pushNamed(context, '/phoneSignUp');
                                }),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/emailSignIn');
                                },
                                child: EmailLoginButton())
                          ],
                        ))))
          ],
        ));
  }
}
