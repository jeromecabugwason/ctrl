import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

late BluetoothConnection conn;
String deviceAddress = '00:22:09:01:A8:E8';

void testScanDevices() async {
  bool? isAvailable = await FlutterBluetoothSerial.instance.isAvailable;
  bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
  BluetoothState? state = await FlutterBluetoothSerial.instance.state;

  print(isAvailable);
  print(isEnabled);
  print(state);

  FlutterBluetoothSerial.instance.requestEnable();

  // Get a list of all paired devices
  // List<BluetoothDevice> devices =
  //     await FlutterBluetoothSerial.instance.getBondedDevices();

  // for (BluetoothDevice device in devices) {
  //   print(device.name);
  //   print(device.address);
  // }

  // FlutterBluetoothSerial.instance.startDiscovery().listen((e) {
  //   print('name: ${e.device.name} address: ${e.device.address}');

  //   // Check if the device is an HC-05 module
  //   if (e.device.name == 'HC-05') {
  //     print('Found HC-05 module with address ${e.device.address}');

  //     deviceAddress = e.device.address;

  //     FlutterBluetoothSerial.instance.cancelDiscovery();
  //   }
  // });

  // await FlutterBluetoothSerial.instance.getBondStateForAddress(address);

  // bool? isPaired = await FlutterBluetoothSerial.instance
  //     .bondDeviceAtAddress(deviceAddress, pin: '0000');

  // print('bt is paired: $isPaired');

  conn.output.add(Uint8List.fromList(ascii.encode('bebe taym')));

  print('sent');

  // conn.close();

  // bool isBroadcast = conn.input!.isBroadcast;

  // if (isBroadcast) {
  //   List<Uint8List> received = await conn.input!.toList();

  //   for (Uint8List u in received) {
  //     print(u.toString());
  //   }
  // }
}

connect() async {
  conn = await BluetoothConnection.toAddress(deviceAddress);

  print('Bluetooth is connected: ${conn.isConnected}');
}

late Stream<Uint8List>? stream;

startListening() {
  stream = conn.input;

  stream!.listen((e) {
    print(ascii.decode(e));
  });
}

disconnect() {
  conn.close();
}
