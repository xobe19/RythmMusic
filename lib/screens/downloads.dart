import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/currentPlaylist.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doesSongExistinPlaylist.dart';
import '../models/getSongIdList.dart';
import '../models/getSongDetailsForCurrentIdFromLocalDb.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'errorPage.dart';

class DownloadsScreen extends StatelessWidget {
  String p;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSongIdList(),
        builder: (BuildContext context, snapshot) {
          print(
              'fucking hell ==================================================================');
          print(snapshot.data);
          if (snapshot.hasError) {
            print(snapshot.error);
            return ErrorPage();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);
            if (snapshot.data == null) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 100),
                    Text('No Downloads Currently',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center)
                  ],
                )),
              );
            }
            CurrentPlaylist data =
                Provider.of<CurrentPlaylist>(context, listen: false);
            data.snpsht = snapshot.data;
            return StfulDl(data: data);
          }
          return Scaffold(
            backgroundColor: Colors.black,
            body:
                Center(child: SpinKitWave(color: Color(0xffbb86fc), size: 50)),
          );
        });
  }
}

class StfulDl extends StatefulWidget {
  const StfulDl({
    Key key,
    @required this.data,
  }) : super(key: key);

  final CurrentPlaylist data;

  @override
  _StfulDlState createState() => _StfulDlState();
}

class _StfulDlState extends State<StfulDl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x101820ff),
        body: Stack(alignment: Alignment.centerRight, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //TODO: image
              Expanded(
                  child: Image.asset('images/download.jpg', fit: BoxFit.cover)),

              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: FutureBuilder(
                        future: getImage(widget.data.snpsht[index]),
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData) {
                            return CircleAvatar(
                                backgroundImage: MemoryImage(snapshot2.data));
                          }
                          return Container(
                              color: Colors.black, width: 10, height: 10);
                        },
                      ),
                      title: FutureBuilder(
                        future: getTitle(widget.data.snpsht[index]),
                        builder: (context, snapshot3) {
                          if (snapshot3.hasData) {
                            return Text(
                                snapshot3.data
                                    .replaceAll("&quot;", "\"")
                                    .replaceAll("&#039;", "'")
                                    .replaceAll("&amp;", "&"),
                                style: TextStyle(color: Colors.white));
                          }
                          return Text('');
                        },
                      ),
                      subtitle: FutureBuilder(
                        future: getArtist(widget.data.snpsht[index]),
                        builder: (context, snapshot5) {
                          if (snapshot5.hasData) {
                            return Text(
                                snapshot5.data
                                    .replaceAll("&quot;", "\"")
                                    .replaceAll("&#039;", "'")
                                    .replaceAll("&amp;", "&"),
                                style: TextStyle(color: Colors.white));
                          }
                          return Text('');
                        },
                      ),
                      onTap: () async {
                        widget.data.fromPlaylistClick = true;
                        widget.data.checker = false;
                        widget.data.currentPlaying = index;
                        var imgData = await getImage(widget.data.snpsht[index]);
                        widget.data.currImage = Image.memory(imgData);
                        if (widget.data.currentAudioPlayer != null) {
                          await widget.data.currentAudioPlayer.stop();
                        }
                        widget.data.currentAudioPlayer = AudioPlayer();

                        widget.data.fromDownload = true;
                        widget.data.currentPlayingMaxVal =
                            widget.data.currentAudioPlayer.duration;
                        widget.data.subs2 = widget
                            .data.currentAudioPlayer.onPlayerStateChanged
                            .listen((s) {
                          if (s == AudioPlayerState.PLAYING) {
                            widget.data.checker = true;
                            widget.data.isPlaying = true;
                            (() => widget.data.currentPlayingMaxVal =
                                widget.data.currentAudioPlayer.duration)();
                          }
                          widget.data.subs2.cancel();
                        });

                        final file = new File(
                            '${(await getTemporaryDirectory()).path}/music.mp3');
                        Uint8List songDataTemp =
                            await getSong(widget.data.snpsht[index]);
                        await file.writeAsBytes(songDataTemp,
                            mode: FileMode.write);
                        await widget.data.currentAudioPlayer
                            .play(file.path, isLocal: true);

                        widget.data.currentPlayingCurrVal = Duration.zero;
                        widget.data.locally.cancelAll().then((_) async {
                          widget.data.locally.show(
                              title: 'Currenty Playing ' +
                                  await getTitle(widget
                                      .data.snpsht[widget.data.currentPlaying]),
                              message: 'Tap to return to app',
                              importance: Importance.low,
                              priority: Priority.min,
                              color: Color(0xffbb86fc));
                        });
                        Navigator.pushNamed(context, '/downloadSongScreen');
                        widget.data.fromPlaylistClick = false;
                      },
                    );
                  },
                  itemCount: widget.data.snpsht.length,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '   ' + 'Downloads' + '   ',
                    style: TextStyle(
                        backgroundColor: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color(0xffbb86fc)),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  widget.data.snpsht.shuffle();
                  widget.data.checker = false;
                  widget.data.fromPlaylistClick = true;
                  widget.data.currentPlaying = 0;
                  var imgData = await getImage(widget.data.snpsht[0]);
                  widget.data.currImage = Image.memory(imgData);
                  if (widget.data.currentAudioPlayer != null) {
                    await widget.data.currentAudioPlayer.stop();
                  }
                  widget.data.currentAudioPlayer = AudioPlayer();

                  widget.data.currentPlayingMaxVal =
                      widget.data.currentAudioPlayer.duration;
                  widget.data.subs2 = widget
                      .data.currentAudioPlayer.onPlayerStateChanged
                      .listen((s) {
                    if (s == AudioPlayerState.PLAYING) {
                      widget.data.isPlaying = true;
                      widget.data.checker = true;
                      (() => widget.data.currentPlayingMaxVal =
                          widget.data.currentAudioPlayer.duration)();
                    }
                    widget.data.subs2.cancel();
                  });

                  final file = new File(
                      '${(await getTemporaryDirectory()).path}/music.mp3');
                  Uint8List songDataTemp = await getSong(widget.data.snpsht[0]);
                  await file.writeAsBytes(songDataTemp, mode: FileMode.write);
                  await widget.data.currentAudioPlayer
                      .play(file.path, isLocal: true);

                  widget.data.currentPlayingCurrVal = Duration.zero;
                  Navigator.pushNamed(context, '/downloadSongScreen');

                  widget.data.fromDownload = true;
                  widget.data.fromPlaylistClick = false;
                  setState(() {});
                },
                child: Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                        color: Color(0xffbb86fc), shape: BoxShape.circle),
                    child: Center(
                        child: FaIcon(FontAwesomeIcons.random,
                            color: Colors.black, size: 40))),
              )
            ],
          )
        ]));
  }
}
