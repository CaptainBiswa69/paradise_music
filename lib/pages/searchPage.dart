import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../myTheme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = "";
  final OnAudioQuery _onAudioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  playSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uri = prefs.getString("uri");
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: TextFormField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
              hintText: "Search", hintStyle: TextStyle(color: Colors.white70)),
        )),
        backgroundColor: myTheme.primaryColor,
        body: FutureBuilder<List<dynamic>>(
            future: _onAudioQuery.queryWithFilters(
              searchText,
              WithFiltersType.AUDIOS,
              args: AudiosArgs.TITLE,
            ),
            builder: (context, item) {
              if (item.data == null) {
                return Container();
              }
              List<SongModel>? items =
                  item.data!.map((e) => SongModel(e)).toList();
              if (items.isEmpty) {
                return const Center(
                  child: Text("No Songs Found"),
                );
              }
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    if (items[index].duration! < 180) {
                      return Container();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: QueryArtworkWidget(
                            id: items[index].id, type: ArtworkType.AUDIO),
                        title: Text(
                          items[index].title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          items[index].artist.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: GestureDetector(
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.red,
                          ),
                          onTap: () {
                            if (_audioPlayer.playing) {
                              setState(() {
                                _audioPlayer.pause();
                              });
                            } else {
                              setState(() {
                                _audioPlayer.play();
                              });
                            }
                          },
                        ),
                        onTap: () {
                          setState(() {
                            forString("uri", items[index].uri!);
                            forInt("musicID", items[index].id);
                            forInt("duration", items[index].duration!);
                            forString("artist", items[index].artist!);
                            forString("title", items[index].title);
                          });
                          playSong();
                        },
                      ),
                    );
                  });
            }));
  }

  Future<void> forString(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(key, data);
    });
  }

  Future<void> forInt(String key, int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt(key, data);
    });
  }
}
