import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../api/api.dart';
import '../models/currentPlaylist.dart';
import 'package:provider/provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'playlistScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doesSongExistinPlaylist.dart';
import 'package:locally/locally.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Debouncer {
  final Duration delay;
  Timer _timer;

  Debouncer({this.delay});

  run(Function action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  StreamController controller = StreamController();
  Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));
  var searchJson;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'search',
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffbb86fc),
                ),
                onChanged: (String search) {
                  if (search == '') {
                    controller.add('fuck');
                  } else {
                    _debouncer.run(() async {
                      controller.add('searching');
                      var tmpSearch = await http
                          .get(Uri.parse(Api.search_base_url + search));
                      searchJson = await json.decode(tmpSearch.body);
                      controller.add('searching done');
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: controller.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print('start');
                    print(snapshot.data);
                    if (snapshot.data == 'searching') {
                      return Center(
                          child:
                              SpinKitRing(color: Color(0xffbb86fc), size: 50));
                    }
                    if (snapshot.data == 'searching done') {
                      return Column(
                        children: [
                          Text(
                            'Songs',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: Image.network(searchJson['songs']
                                      ['data'][index]['image']),
                                  title: Text(
                                      searchJson['songs']['data'][index]
                                              ['title']
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&#039;", "'")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: Colors.white)),
                                  subtitle: Text(
                                      searchJson['songs']['data'][index]
                                              ['more_info']['primary_artists']
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&#039;", "'")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () async {
                                    var data = Provider.of<CurrentPlaylist>(
                                        context,
                                        listen: false);
                                    data.checker = false;

                                    data.fromPlaylistClick = true;
                                    data.currentPlaying = 0;
                                    data.playlistId = 'songPlayingRn';
                                    data.currImage = Image.network(
                                        searchJson['songs']['data'][index]
                                                ['image']
                                            .replaceAll('50x50', '500x500'));

                                    var encUrl1 = await http.get(Uri.parse(
                                        Api.song_details_base_url +
                                            searchJson['songs']['data'][index]
                                                ['id']));
                                    var encUrl2 =
                                        await json.decode(encUrl1.body);

                                    data.decrytpedUrl = await data
                                        .getDecryptedUrlWithString(encUrl2[
                                            searchJson['songs']['data'][index]
                                                ['id']]['encrypted_media_url']);

                                    data.jsonData = Map<String, dynamic>();

                                    data.jsonData['title'] = encUrl2[
                                        searchJson['songs']['data'][index]
                                            ['id']]['song'];
                                    data.jsonData['songs'] = [
                                      encUrl2[searchJson['songs']['data'][index]
                                          ['id']]
                                    ];

                                    if (data.currentAudioPlayer != null) {
                                      await data.currentAudioPlayer.stop();
                                      print('1');
                                    }
                                    print('1');
                                    data.currentAudioPlayer = AudioPlayer();
                                    print('1');
                                    await data.currentAudioPlayer
                                        .play(data.decrytpedUrl);
                                    data.currentPlayingMaxVal = Duration.zero;

                                    data.fromDownload = false;
                                    data.currentPlayingMaxVal =
                                        data.currentAudioPlayer.duration;
                                    data.currentPlayingCurrVal = Duration.zero;
                                    data.subs2 = data
                                        .currentAudioPlayer.onPlayerStateChanged
                                        .listen((s) {
                                      if (s == AudioPlayerState.PLAYING) {
                                        data.checker = true;
                                        data.isPlaying = true;
                                        (() => data.currentPlayingMaxVal =
                                            data.currentAudioPlayer.duration)();
                                      }
                                      data.subs2.cancel();
                                    });

                                    var songId = data.jsonData['songs']
                                        [data.currentPlaying]['id'];
                                    var uid =
                                        FirebaseAuth.instance.currentUser.uid;
                                    data.isLiked =
                                        await doesSongExistInPlaylist(
                                            uid, songId);
                                    Navigator.pop(context);
                                    data.locally.cancelAll().then((_) {
                                      data.locally.show(
                                          title: 'Currenty Playing ' +
                                              searchJson['songs']['data'][index]
                                                  ['title'],
                                          message: 'Tap to return to app',
                                          importance: Importance.low,
                                          priority: Priority.min,
                                          color: Color(0xffbb86fc));
                                    });
                                    Navigator.pushNamed(context, '/songScreen');
                                    data.fromPlaylistClick = false;
                                  },
                                );
                              },
                              itemCount: searchJson['songs']['data'].length),
                          Text(
                            'Albums',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: Image.network(searchJson['albums']
                                    ['data'][index]['image']),
                                title: Text(
                                    searchJson['albums']['data'][index]['title']
                                        .replaceAll("&quot;", "\"")
                                        .replaceAll("&#039;", "'")
                                        .replaceAll("&amp;", "&"),
                                    style: TextStyle(color: Colors.white)),
                                subtitle: Text(
                                    searchJson['albums']['data'][index]['music']
                                        .replaceAll("&quot;", "\"")
                                        .replaceAll("&#039;", "'")
                                        .replaceAll("&amp;", "&"),
                                    style: TextStyle(color: Colors.white)),
                                onTap: () async {
                                  await Provider.of<CurrentPlaylist>(context,
                                          listen: false)
                                      .init(searchJson['albums']['data'][index]
                                          ['id']);

                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return PlaylistScreen(searchJson['albums']
                                        ['data'][index]['id']);
                                  }));
                                },
                              );
                            },
                            itemCount: searchJson['albums']['data'].length,
                            shrinkWrap: true,
                          ),
                        ],
                      );
                    }
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 100),
                        SizedBox(
                          height: 15,
                        ),
                        Text('Search for Albums/Songs',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                      ],
                    ));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
