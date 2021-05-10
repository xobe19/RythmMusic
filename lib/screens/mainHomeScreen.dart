import 'package:flutter/material.dart';
import '../screens/searchScreen.dart';
import '../screens/downloads.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/currentPlaylist.dart';
import '../models/getPlaylistOfUsers.dart';
import 'errorPage.dart';
import 'userPlaylistScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/createPlaylist.dart';
import 'createPlaylistScreen.dart';
import '../models/doesSongExistinPlaylist.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<List> initF(BuildContext context) async {
  await getPlaylistOfUsers().then((value) {
    if (value.length == 0) {
      createPlaylist(FirebaseAuth.instance.currentUser.uid);
    }
  });

  var arr = [
    SizedBox(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DownloadsScreen();
          }));
        },
        child: Card(
          color: Colors.black,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: FaIcon(FontAwesomeIcons.download,
                      size: 100, color: Color(0xffbb86fc))),
              SizedBox(height: 10),
              Text('Downloads',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ),
    SizedBox(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return UserPlaylistScreen(FirebaseAuth.instance.currentUser.uid);
          }));
        },
        child: Card(
          color: Colors.black,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: FaIcon(FontAwesomeIcons.solidHeart,
                      size: 100, color: Color(0xffbb86fc))),
              SizedBox(height: 10),
              Text('Liked Songs',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    )
  ];

  List datList = await getPlaylistOfUsers();
  for (int i = 0; i < datList.length; i++) {
    if (datList[i]['playlistId'] == FirebaseAuth.instance.currentUser.uid) {
      // do nothing
    } else {
      Widget tbp = SizedBox(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return UserPlaylistScreen(datList[i]['playlistId']);
            }));
          },
          child: Card(
            color: Colors.black,
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                datList[i]['image'] == null
                    ? Container(
                        padding: EdgeInsets.all(12),
                        alignment: Alignment.center,
                        color: Colors.black,
                        child: FaIcon(FontAwesomeIcons.hashtag,
                            size: 100, color: Color(0xffbb86fc)))
                    : Image.network(datList[i]['image'],
                        width: 120, height: 120),
                SizedBox(height: 10),
                Text(datList[i]['title'],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );

      arr.add(tbp);
    }
  }
  arr.add(SizedBox(
    child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Cpl();
        }));
      },
      child: Card(
        color: Colors.black,
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.all(12),
                alignment: Alignment.center,
                color: Colors.black,
                child: FaIcon(FontAwesomeIcons.plus,
                    size: 100, color: Color(0xffbb86fc))),
            SizedBox(height: 10),
            Text('Create Playlist',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  ));
  return arr;
}

class MainHomeScreen extends StatefulWidget {
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<CurrentPlaylist>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return ErrorPage();
            }
            if (snapshot.hasData) {
              return Scaffold(
                  backgroundColor: Colors.black,
                  floatingActionButton: FloatingActionButton.extended(
                    backgroundColor: Color(0xffbb86fc),
                    onPressed: () {
                      if (data.fromDownload == false) {
                        Navigator.pushNamed(context, '/songScreen');
                      } else if (data.fromDownload == true) {
                        Navigator.pushNamed(context, '/downloadSongScreen');
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.music_note,
                                    color: Colors.white, size: 100),
                                Text('No Song Playing Right Now.',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center)
                              ],
                            )),
                          );
                        }));
                      }
                    },
                    label: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Now Playing ",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          //TODO
                        ],
                      ),
                    ),
                    icon: Icon(Icons.music_note, size: 17, color: Colors.black),
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/aboutPage');
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Icon(Icons.settings,
                                      color: Colors.white, size: 30)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              'Library',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                                child: Hero(
                                  tag: 'search',
                                  child: TextField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xffbb86fc),
                                      enabled: false,
                                      labelText: 'Search any Song/Album',
                                      suffixIcon: Icon(Icons.search,
                                          color: Colors.black),
                                      border: new OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return SearchScreen();
                                  }));
                                }),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Your Playlists',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Top Picks',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: FutureBuilder(
                                future: Provider.of<CurrentPlaylist>(context,
                                        listen: false)
                                    .initUser('Top Picks===CEAsS'),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    var data = Provider.of<CurrentPlaylist>(
                                        context,
                                        listen: false);
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 7.5,
                                              childAspectRatio: 16 / 9),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          leading: Image.network(
                                            data.jsonData['songs'][index]
                                                ['image'],
                                          ),
                                          title: Text(
                                              data.jsonData['songs'][index]
                                                  ['song'],
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              data.jsonData['songs'][index]
                                                  ['primary_artists'],
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onTap: () async {
                                            if (data.playlistId !=
                                                'Top Picks===CEAsS') {
                                              await Provider.of<
                                                          CurrentPlaylist>(
                                                      context,
                                                      listen: false)
                                                  .initUser(
                                                      'Top Picks===CEAsS');
                                              data =
                                                  Provider.of<CurrentPlaylist>(
                                                      context,
                                                      listen: false);
                                            }
                                            data.checker = false;
                                            data.fromPlaylistClick = true;
                                            data.currentPlaying = index;
                                            data.currImage = Image.network(data
                                                .jsonData['songs']
                                                    [data.currentPlaying]
                                                    ['image']
                                                .replaceAll(
                                                    '150x150', '500x500'));
                                            print('1');
                                            data.decrytpedUrl =
                                                await data.getDecryptedUrl();
                                            if (data.currentAudioPlayer !=
                                                null) {
                                              await data.currentAudioPlayer
                                                  .stop();
                                              print('1');
                                            }
                                            print('1');
                                            data.currentAudioPlayer =
                                                AudioPlayer();
                                            print('1');
                                            await data.currentAudioPlayer
                                                .play(data.decrytpedUrl);
                                            data.currentPlayingMaxVal =
                                                Duration.zero;

                                            data.currentPlayingMaxVal = data
                                                .currentAudioPlayer.duration;
                                            data.currentPlayingCurrVal =
                                                Duration.zero;
                                            data.fromDownload = false;
                                            print('1');
                                            print('yaha');
                                            data.subs2 = data.currentAudioPlayer
                                                .onPlayerStateChanged
                                                .listen((s) {
                                              if (s ==
                                                  AudioPlayerState.PLAYING) {
                                                data.checker = true;
                                                data.isPlaying = true;
                                                (() =>
                                                    data.currentPlayingMaxVal =
                                                        data.currentAudioPlayer
                                                            .duration)();
                                              }
                                              data.subs2.cancel();
                                            });

                                            var songId = data.jsonData['songs']
                                                [data.currentPlaying]['id'];
                                            var uid = FirebaseAuth
                                                .instance.currentUser.uid;
                                            data.isLiked =
                                                await doesSongExistInPlaylist(
                                                    uid, songId);

                                            Navigator.pushNamed(
                                                context, '/songScreen');
                                            data.fromPlaylistClick = false;

                                            data.locally.cancelAll().then((_) {
                                              data.locally.show(
                                                  title: 'Currenty Playing ' +
                                                      data.jsonData['songs'][data
                                                              .currentPlaying]
                                                          ['song'],
                                                  message:
                                                      'Tap to return to app',
                                                  importance: Importance.low,
                                                  priority: Priority.min,
                                                  color: Color(0xffbb86fc));
                                            });
                                          },
                                        );
                                      },
                                      itemCount: data.jsonData['songs'].length,
                                    );
                                  }
                                  return Center(
                                      child: SpinKitWave(
                                    color: Color(0xffbb86fc),
                                    size: 50,
                                  ));
                                }),
                          )
                        ],
                      ),
                    ),
                  ));
            }
            return SpinKitWave(color: Color(0xffbb86fc), size: 50);
          },
          future: initF(context)),
    );
  }
}
