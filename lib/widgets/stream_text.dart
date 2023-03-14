// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class StreamText extends StatefulWidget {
  final Stream<String> textStream;

  const StreamText({super.key, required this.textStream});

  @override
  _StreamTextState createState() => _StreamTextState();
}

class _StreamTextState extends State<StreamText> {
  late ScrollController _controller;
  final List<String> _lines = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    widget.textStream.listen((String data) {
      setState(() {
        _lines.add(data);
      });
      // Scroll to the bottom of the ListView when new data is added
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Text(
            _lines[index],
          ),
        );
      },
    );
  }
}
