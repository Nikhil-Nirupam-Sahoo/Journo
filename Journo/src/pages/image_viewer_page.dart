import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (_) => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}