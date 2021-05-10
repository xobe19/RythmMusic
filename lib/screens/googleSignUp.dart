import 'package:flutter/material.dart';
import '../screens/loadingScreen.dart';
import '../auth/googleAuth.dart';
import 'errorPage.dart';
import '../screens/playlistScreen.dart';
import '../screens/searchScreen.dart';
import '../screens/userPlaylistScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/createPlaylist.dart';
import '../screens/mainHomeScreen.dart';
import '../models/getPlaylistOfUsers.dart';
class GoogleSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: signInWithGoogle(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPage();
          }
          if (snapshot.connectionState == ConnectionState.done) {
//Navigator.pushNamedAndRemoveUntil(context, '/homeScreenSongs', ModalRoute.withName('/'));
//   return UserPlaylistScreen('my one and only playlist===gZFVk');
		  return MainHomeScreen();
          }
          return LoadingScreen('Connecting to your Google Account');
        });
  }
}
