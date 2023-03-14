// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({Key? key}) : super(key: key);

  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    isConnected = checkConnection();
  }

  bool checkConnection() {
    // Implement your logic to check the connection status here
    return false; // Return true if the device is connected, false otherwise
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: kToolbarHeight, // Use the same height as AppBar
            color:
                Theme.of(context).primaryColor, // Use the same color as AppBar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: Icon(
                      isConnected
                          ? Icons.bluetooth_connected // Use connected icon
                          : Icons.bluetooth_disabled, // Use disconnected icon
                      color: isConnected
                          ? Colors.green
                          : null, // Set green color for connected icon
                    ),
                    onPressed: () {
                      // Bluetooth icon logic...
                    },
                  ),
                )
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  // Your scrolling text here...
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod tortor vitae mauris lobortis consectetur. Pellentesque sed dui sit amet nibh fringilla lacinia vel quis velit. Nam convallis, ipsum vitae laoreet tempor, nulla mi suscipit eros, a ullamcorper nisl turpis at odio. Etiam id augue quis leo gravida bibendum eu vitae lacus. Integer feugiat dolor nec nibh maximus, sed auctor nisl aliquam. Nulla pharetra lorem eu velit malesuada, id tincidunt orci auctor. Integer viverra, ipsum vel varius bibendum, sapien dolor pulvinar nulla, at sollicitudin sapien dolor sed turpis. Donec eget metus orci. Proin rutrum vel lacus euismod tristique. Mauris lacinia justo sit amet magna vulputate imperdiet. Duis in tortor non sapien vehicula tincidunt.',
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message here',
                    suffixIcon: IconButton(
                      onPressed: () {
                        // Send message logic...
                      },
                      icon: const Icon(Icons.send,
                          color: Colors
                              .green), // Set green color for the send icon
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Start Listening button logic...
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .orange, // Set orange color for Start Listening button
                      ),
                      child: const Text('Start Listening'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Disconnect button logic...
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Set red color for Disconnect button
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
