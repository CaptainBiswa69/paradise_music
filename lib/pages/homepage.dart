import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../myTheme.dart';
import '../widgets/mainDrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final OnAudioQuery _onAudioQuery = OnAudioQuery();
  late AudioPlayer _audioPlayer;
  bool permissionGranted = false;
  late Stream<DurationState> _durationState;
  String? title = "";
  String? artist = "";
  String? uri = "";
  int? musicID = 0;
  int? duration = 0;

  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getStoragePermission();
    setState(() {});
    _audioPlayer = AudioPlayer();
    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _audioPlayer.positionStream,
        _audioPlayer.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration!,
            ));
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldState,
        drawer: const MainDrawer(),
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        backgroundColor: myTheme.primaryColor,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _scaffoldState.currentState?.openDrawer();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 0.5,
                                  color: const Color.fromARGB(
                                      255, 157, 151, 151))),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.menu,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 0.5,
                                  color: const Color.fromARGB(
                                      255, 157, 151, 151))),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => const SearchPage()));
                        },
                      ),
                    ],
                  ),
                ),
                permissionGranted
                    ? FutureBuilder<List<SongModel>>(
                        future: _onAudioQuery.querySongs(
                            sortType: SongSortType.TITLE,
                            ignoreCase: true,
                            uriType: UriType.EXTERNAL,
                            orderType: OrderType.ASC_OR_SMALLER),
                        builder: (context, item) {
                          if (item.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (item.data!.isEmpty) {
                            return const Center(
                              child: Text("No Songs Found"),
                            );
                          }
                          return Expanded(
                            child: ListView.builder(
                                itemCount: item.data!.length,
                                itemBuilder: (context, index) {
                                  if (item.data![index].duration! < 180) {
                                    return Container();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: QueryArtworkWidget(
                                          id: item.data![index].id,
                                          type: ArtworkType.AUDIO),
                                      title: item.data![index].id == musicID
                                          ? Text(
                                              item.data![index].title,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            )
                                          : Text(
                                              item.data![index].title,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                      subtitle: item.data![index].id == musicID
                                          ? Text(
                                              item.data![index].artist
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            )
                                          : Text(
                                              item.data![index].artist
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                      trailing: GestureDetector(
                                        child:
                                            item.data![index].id == musicID &&
                                                    _audioPlayer.playing
                                                ? const Icon(
                                                    Icons.pause,
                                                    color: Colors.red,
                                                  )
                                                : const Icon(
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
                                          forString(
                                              "uri", item.data![index].uri!);
                                          forString(
                                              "title", item.data![index].title);
                                          forInt(
                                              "musicID", item.data![index].id);
                                          forString("artist",
                                              item.data![index].artist!);
                                          forInt("duration",
                                              item.data![index].duration!);
                                        });
                                        playSong(item.data![index].uri!);
                                      },
                                    ),
                                  );
                                }),
                          );
                        })
                    : const Center(
                        child: Text(
                        "Need storage permission",
                        style: TextStyle(color: Colors.white),
                      )),
              ],
            ),
          ],
        ));
  }

  Card playWidget() {
    return Card(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          StreamBuilder<DurationState>(
            stream: _durationState,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.progress ?? Duration.zero;
              final buffered = durationState?.buffered ?? Duration.zero;
              final total = durationState?.total ?? Duration.zero;
              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: ProgressBar(
                  progress: progress,
                  buffered: buffered,
                  total: total,
                  progressBarColor: Colors.red,
                  baseBarColor: Colors.white.withOpacity(0.24),
                  bufferedBarColor: Colors.black,
                  thumbRadius: 5,
                  barHeight: 3.0,
                  timeLabelLocation: TimeLabelLocation.none,
                  onSeek: (duration) {
                    _audioPlayer.seek(duration);
                  },
                ),
              );
            },
          ),
          Card(
            elevation: 5,
            child: ListTile(
                leading: QueryArtworkWidget(
                  id: musicID!,
                  type: ArtworkType.AUDIO,
                ),
                title: Text(title!),
                subtitle: Text(artist!),
                trailing: _audioPlayer.playing
                    ? InkWell(
                        child: const Icon(
                          Icons.pause,
                          color: Colors.red,
                          size: 35,
                        ),
                        onTap: () {
                          _audioPlayer.pause();
                          setState(() {});
                        },
                      )
                    : InkWell(
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.red,
                          size: 35,
                        ),
                        onTap: () {
                          _audioPlayer.play();
                          setState(() {});
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      setState(() {
        permissionGranted = false;
      });
    }
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

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    musicID = prefs.getInt("musicID") ?? 0;
    title = prefs.getString("title") ?? "";
    artist = prefs.getString("artist") ?? "";
    uri = prefs.getString("uri") ?? "";
    duration = prefs.getInt("duration") ?? 0;
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
