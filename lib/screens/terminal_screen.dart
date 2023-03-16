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
  final BluetoothController bluetoothController = BluetoothApi().getController;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final Stream<String> _logStream;

  bool _isConnected = false;

  void _handleTextFieldSubmit(String str) {
    setState(() {
      _textEditingController.clear();
      bluetoothController.send(str);
    });
  }

  bool _checkConnection() {
    return bluetoothController.checkConnection();
  }

  void _handleClearConsole() {
    setState(() {
      Console.clear();
    });
  }

  Future<void> _handleConnection() async {
    await bluetoothController.connect();

    setState(() {
      _isConnected = bluetoothController.checkConnection();
    });
  }

  @override
  void initState() {
    super.initState();

    _isConnected = _checkConnection();

    _logStream = Console.logStream;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    Console.close();
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isConnected
                              ? Icons.bluetooth_connected // Use connected icon
                              : Icons
                                  .bluetooth_disabled, // Use disconnected icon
                          color: _isConnected ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _handleConnection,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _handleClearConsole,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamText(
                textStream: _logStream,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textEditingController,
                    onSubmitted: (str) {
                      _handleTextFieldSubmit(str);
                      _focusNode.requestFocus();
                    },
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your command here',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _handleTextFieldSubmit(_textEditingController.text);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.deepPurpleAccent,
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
