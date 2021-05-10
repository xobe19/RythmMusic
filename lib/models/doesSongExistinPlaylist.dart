import 'package:cloud_firestore/cloud_firestore.dart';
Future<bool> doesSongExistInPlaylist (String playlistString, String songId) async {
FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference c1 = firestore.collection('playlists');
QuerySnapshot qs = await c1.where('playlistString', isEqualTo: playlistString).get();
QuerySnapshot l = await qs.docs[0].reference.collection(
		'songs'
		).where('songId', isEqualTo: songId).get();
return l.docs.length > 0;
}
