import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rythm_app/models/currentPlaylist.dart';
import '../models/getPlaylistOfUsers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/addSongToPlaylist.dart';
import 'errorPage.dart';

class AddToPlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userPlaylists = getPlaylistOfUsers();

    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text('Select Playlist: ',
                    style: TextStyle(
                        color: Color(0xffbb86fc),
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                  flex: 7,
                  child: FutureBuilder(
                    future: userPlaylists,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorPage();
                      }
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(
                                    '+ ' + snapshot.data[index]['title'],
                                    style: TextStyle(color: Colors.white)),
                                onTap: () async {
                                  var data = Provider.of<CurrentPlaylist>(
                                      context,
                                      listen: false);
                                  await addSongToPlaylist(
                                      snapshot.data[index]['playlistId'],
                                      data.jsonData['songs']
                                          [data.currentPlaying]);
                                  print('data added');
                                  //TODO: open playlists id;
                                },
                              );
                            });
                      }
                      return SpinKitWave(size: 50, color: Color(0xffbb86fc));
                    },
                  ))
            ],
          ),
        ));
  }
}
