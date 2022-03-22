import 'dart:convert';
import 'dart:typed_data';
import 'package:des_plugin/des_plugin.dart';

class Api {
  static const search_base_url =
      "https://www.jiosaavn.com/api.php?__call=autocomplete.get&_format=json&_marker=0&cc=in&includeMetaTags=1&query=";
  static const song_details_base_url =
      "https://www.jiosaavn.com/api.php?__call=song.getDetails&cc=in&_marker=0%3F_marker%3D0&_format=json&pids=";
  static const album_details_base_url =
      "https://www.jiosaavn.com/api.php?__call=content.getAlbumDetails&_format=json&cc=in&_marker=0%3F_marker%3D0&albumid=";
  static const playlist_details_base_url =
      "https://www.jiosaavn.com/api.php?__call=playlist.getDetails&_format=json&cc=in&_marker=0%3F_marker%3D0&listid=";
  static const lyrics_base_url =
      "https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&ctx=web6dot0&api_version=4&_format=json&_marker=0%3F_marker%3D0&lyrics_id=";
  static const key = '38346591';
  static Future<String> decrypt(String jsonData) async {
    print(
        "-=======================================================================");
    print(jsonData);
    print(
        "-=======================================================================");
    var list = new List<int>();
    jsonData.runes.forEach((rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    Uint8List bytes = Uint8List.fromList(list);
    print(
        "-=======================================================================");
    print(jsonData);
    print(
        "-=======================================================================");
    return await DesPlugin.decrypt(key, jsonData);
  }
}
