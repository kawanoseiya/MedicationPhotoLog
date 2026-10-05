import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 写真の全画面表示。ピンチで拡大、左右でページ送り。
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.files, this.initialIndex = 0});

  final List<File> files;
  final int initialIndex;

  static Future<void> open(
    BuildContext context,
    List<File> files, {
    int initialIndex = 0,
  }) => Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PhotoViewer(files: files, initialIndex: initialIndex),
    ),
  );

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.files.length > 1
            ? Text(
                l10n.pageOf(_index + 1, widget.files.length),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.files.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Center(
            child: Image.file(
              widget.files[i],
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
