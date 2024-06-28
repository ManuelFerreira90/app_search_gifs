import 'package:app_gifs/model/gif.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  const GifPage({super.key, required this.gif});

  final Gif gif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gif.title),
        actions: [
          IconButton(
            onPressed: () {
              Share.share(gif.image);
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Center(
        child: Image.network(gif.image),
      ),
    );
  }
}
