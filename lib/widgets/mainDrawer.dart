import 'package:flutter/material.dart';

import '../pages/playlist.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff7293c1),
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: const EdgeInsets.only(top: 50),
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text('Playlists'),
            onTap: () {
              Navigator.of(context)
                  .push(
                      MaterialPageRoute(builder: (context) => const PlayList()))
                  .whenComplete(() => Navigator.pop(context));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favourits'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
