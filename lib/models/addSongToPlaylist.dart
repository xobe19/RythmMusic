import 'package:cloud_firestore/cloud_firestore.dart';
Future<bool> addSongToPlaylist(String playlistString, songData) async {
FirebaseFirestore firstore = FirebaseFirestore.instance;
CollectionReference playlistCollection = firstore.collection('playlists');
QuerySnapshot qs = await playlistCollection.where('playlistString', isEqualTo : playlistString).get();
print('=======');
print(qs.docs);

	
await qs.docs[0].reference.collection('songs').add({


	'songId' : songData['id'],
	'songData': songData
});
qs.docs[0].reference.update({
	'image': songData['image']

});



}


