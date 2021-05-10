import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List> getPlaylistOfUsers() async {
	var tbr = [];
	try {

FirebaseAuth auth = FirebaseAuth.instance;
User currUser = auth.currentUser;
FirebaseFirestore firestore = FirebaseFirestore.instance;
QuerySnapshot qs = await firestore.collection('users').where('userName', isEqualTo: currUser.uid).get();
QuerySnapshot qs2 = await qs.docs[0].reference.collection('userPlaylists').get();
List resp = await Future.wait(

qs2.docs.map( (DocumentSnapshot documentSnapshot) async { 

var pid = await documentSnapshot.get('playlistId');
QuerySnapshot qs3 = await firestore.collection('playlists').where('playlistString', isEqualTo: pid).get();
return ({'image': await qs3.docs[0].get('image'), 'title': await qs3.docs[0].get('title'), 'playlistId': pid});
})
		);
return resp;

	} catch(e) {
       tbr = []; 
	}
return tbr;
}
