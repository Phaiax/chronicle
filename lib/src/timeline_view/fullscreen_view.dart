import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenView extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const FullScreenView(
      {required this.imagePath, required this.heroTag, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
      ),
    );
  }
}
