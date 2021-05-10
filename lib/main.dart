import 'package:flutter/material.dart';
import 'package:rythm_app/screens/errorPage.dart';
import 'screens/homeScreen.dart';
import 'screens/signUp.dart';
import 'screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/emailSignUpInput.dart';
import 'screens/googleSignUp.dart';
import 'screens/facebookSignUp.dart';
import 'models/OtpData.dart';
import 'package:provider/provider.dart';
import 'screens/otp.dart';
import 'screens/phoneSignIn.dart';
import 'screens/emailSignInInput.dart';
import 'screens/songScreen.dart';
import 'models/currentPlaylist.dart';
import 'screens/addToPlaylistScreen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/downloadSongScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/aboutPage.dart';
import 'screens/mainHomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Hive.initFlutter();
  runApp(MultiProvider(
    child: App(),
    providers: [
      Provider<OtpData>(
        create: (_) => OtpData(),
      ),
      Provider<CurrentPlaylist>(
        create: (BuildContext context) {
          var cp = CurrentPlaylist(context);

          return cp;
        },
      )
    ],
  ));
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPage();
            // TODO: implement error page
            // Implement error page todo one more
            // implement error page three notification
          } else if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (BuildContext context) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return HomeScreen();
                  }
                  return MainHomeScreen();
                },
                '/signUp': (BuildContext context) {
                  return SignUp();
                },
                '/login': (BuildContext context) {
                  return Login();
                },
                '/emailLogin': (BuildContext context) {
                  return Text('construction');
                },
                '/emailSignUp': (BuildContext context) {
                  return EmailSignUpInput();
                },
                '/googleSignUp': (BuildContext context) {
                  return GoogleSignUpScreen();
                },
                '/facebookSignUp': (BuildContext context) {
                  return FacebookSignUpScreen();
                },
                '/otpScreen': (BuildContext context) {
                  return Otp();
                },
                '/phoneSignUp': (BuildContext context) {
                  return PhoneSignUp();
                },
                '/emailSignIn': (BuildContext context) {
                  return EmailSignInInput();
                },
                '/songScreen': (BuildContext context) {
                  return SongScreen();
                },
                '/addToPlaylistScreen': (BuildContext context) {
                  return AddToPlaylistScreen();
                },
                '/downloadSongScreen': (BuildContext context) {
                  return DownloadSongScreen();
                },
                '/aboutPage': (BuildContext context) {
                  return AboutPage();
                }
              },
            );
          } else {
            // loading page
            return Container(color: Colors.blue);
          }
        });
  }
}
