import 'package:flutter/material.dart';

class FullScreenView extends StatelessWidget {
  final String imageUrl;

  const FullScreenView({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              imageUrl,
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
