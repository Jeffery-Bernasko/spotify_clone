import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_clone/services/spotify_api.dart';

Future<void> main() async {
  try {
    print('Current Directory: ${Directory.current.path}');
    await dotenv.load(fileName: ".env");
    print("SPOTIFY_CLIENT_ID: ${dotenv.env['SPOTIFY_CLIENT_ID']}");
  } catch (e) {
    print("Dotenv Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final SpotifyApiService spotifyApi = SpotifyApiService();
    return MaterialApp(
      home: Scaffold(
          body: FutureBuilder(
        future: spotifyApi.search('Taylor Swift', 'artist'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final results = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final artist = results[index];
                return ListTile(
                  title: Text(artist['name']),
                  subtitle: Text(artist['popularity'].toString()),
                );
              },
            );
          }
        },
      )),
    );
  }
}
