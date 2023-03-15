// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:ctrl/bluetooth/bluetooth_api.dart';
import 'package:ctrl/bluetooth/bluetooth_controller.dart';
import 'package:ctrl/stream/console/console.dart';
import 'package:flutter/material.dart';
import '../widgets/stream_text.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({Key? key}) : super(key: key);

  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final BluetoothController btApi = BluetoothApi().getController;

  final StreamController<String> _streamController = StreamController<String>();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isConnected = false;

  void _handleTextFieldSubmit(String str) {
    _textEditingController.clear();
    _focusNode.requestFocus();

    btApi.send(str);
  }

  bool _checkConnection() {
    return btApi.checkConnection();
  }

  Future<void> _handleConnection() async {
    bool res = await btApi.connect();

    setState(() {
      _isConnected = res;
    });
  }

  @override
  void initState() {
    super.initState();

    _streamController.addStream(Console.logStream);

    _isConnected = _checkConnection();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _streamController.close(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kToolbarHeight, // Use the same height as AppBar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      'HC-05 Terminal',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          _isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          icon: Icon(
                            _isConnected
                                ? Icons
                                    .bluetooth_connected // Use connected icon
                                : Icons
                                    .bluetooth_disabled, // Use disconnected icon
                            color: _isConnected ? Colors.green : null,
                          ),
                          onPressed: _handleConnection,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamText(
                textStream: _streamController.stream,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textEditingController,
                    onSubmitted: _handleTextFieldSubmit,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your command here',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _handleTextFieldSubmit(_textEditingController.text);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
