import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:rythm_app/screens/homeScreen.dart';
import 'loadingScreen.dart';
import 'errorPage.dart';
import 'mainHomeScreen.dart';

Future<UserCredential> signInWithFacebook() async {
  final LoginResult result = await FacebookAuth.instance.login();
  if (result.status == LoginStatus.success) {
    // Create a credential from the access token
    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken.token);
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  return null;
}

class FacebookSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: signInWithFacebook(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
		  print('fb error ===========================');
		  print(snapshot.error);
            return ErrorPage();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MainHomeScreen();
          }
          return LoadingScreen('Connecting your Facebook Account');
        });
  }
}
