// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:ctrl/stream/console/console.dart';
import 'package:flutter/material.dart';

class StreamText extends StatefulWidget {
  final Stream<String> textStream;

  const StreamText({Key? key, required this.textStream}) : super(key: key);

  @override
  _StreamTextState createState() => _StreamTextState();
}

class _StreamTextState extends State<StreamText> {
  late final ScrollController _controller =
      ScrollController(initialScrollOffset: 0.0);
  final List<String> _lines = [];
  late StreamSubscription<String> _streamSubscription;

  _clearLines() {
    _lines.clear();
  }

  @override
  void initState() {
    super.initState();
    _subscribeToStream();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _subscribeToStream() {
    _streamSubscription = widget.textStream.listen((String data) {
      setState(() {
        _lines.add(data);
      });
      // Scroll to the bottom of the ListView when new data is added
      // ignore: unnecessary_null_comparison
      if (_controller.hasClients && _controller.position != null) {
        try {
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        } catch (e) {
          Console.log('Error: $e');
          _controller.animateTo(
            0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      }

      // clear lines
      if (data == '') {
        setState(() {
          _clearLines();
        });
      }
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
