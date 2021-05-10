import 'package:firebase_auth/firebase_auth.dart';

class EmailAuthenticator {
  FirebaseAuth auth;
  EmailAuthenticator() {
    this.auth = FirebaseAuth.instance;
  }
  signIn(String email, String password) {
    return this
        .auth
        .signInWithEmailAndPassword(email: email, password: password);
  }

  signUp(String email, String password) {
    return this
        .auth
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  getUser(callback) {
    this.auth.authStateChanges().listen(callback);
  }
}
