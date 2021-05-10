import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
FirebaseFirestore firestore = FirebaseFirestore.instance;
   
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
Future<bool> createPlaylist(String playlistName) async {
   String id = getRandomString(5); 
    FirebaseAuth auth = FirebaseAuth.instance;
   String finalId = playlistName == auth.currentUser.uid ? playlistName : playlistName + '===' + id;
   playlistName = playlistName == auth.currentUser.uid ? 'Liked Songs' : playlistName;
   CollectionReference playlistCollection = firestore.collection('playlists');
   CollectionReference usersCollection = firestore.collection('users');
    DocumentReference ref = await playlistCollection.add(
		    {
			    "playlistString": finalId,
			    "image" : null,
			    "title" : playlistName
		    }
		    );
    //ref.collection('songs');
    User currUser;
    currUser = auth.currentUser;
    var userPlaylists = await usersCollection.where('userName', isEqualTo: currUser.uid).get();
      userPlaylists.docs.forEach((DocumentSnapshot documentSnapshot) {
	      documentSnapshot.reference.collection('userPlaylists').add({'playlistId': finalId} );
     });
      if(userPlaylists.docs.length < 1) {
var ref2 = await usersCollection.add(
		   {
     "userName" : currUser.uid,

		   }
		   ); 
ref2.collection('userPlaylists').add({'playlistId' : finalId});
      }
   
    return true;
}
