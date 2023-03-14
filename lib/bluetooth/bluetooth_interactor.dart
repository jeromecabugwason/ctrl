import 'dart:convert';
import 'dart:typed_data';

import 'package:ctrl/bluetooth/bluetooth_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothInteractor {
  // conn - abbreviation of connection
  final FlutterBluetoothSerial _service;
  late String _deviceAddress;
  late BluetoothConnection _conn;

  BluetoothInteractor(this._service);

  bool scanInPairedDevices() {
    bool isFound = false;

    _service.getBondedDevices().then((devices) {
      for (BluetoothDevice device in devices) {
        if (device.name == 'HC-05') {
          isFound = true;
          _deviceAddress = device.address;
        }
      }
    });

    return isFound;
  }

  bool scan() {
    bool isFound = false;

    _service.startDiscovery().listen((e) {
      // Check if the device is an HC-05 module
      if (e.device.name == 'HC-05') {
        isFound = true;
        _deviceAddress = e.device.address;
        _service.cancelDiscovery();
      }
    });

    return isFound;
  }

  Future<void> connect() async {
    _conn = await BluetoothConnection.toAddress(_deviceAddress);

    debugPrint('Bluetooth is connected: ${_conn.isConnected}');
  }

  Future<BluetoothBondState> getBondSate() {
    return _service.getBondStateForAddress(_deviceAddress);
  }

  Future<bool?> pair(String pin) {
    return _service.bondDeviceAtAddress(_deviceAddress, pin: pin);
  }

  bool disconnect() {
    bool isSuccess = false;

    _conn
        .close()
        .then((value) => isSuccess = true)
        .onError((error, stackTrace) => isSuccess = false);

    return isSuccess;
  }

  Stream<String> startListening() {
    return conn.input!.map(ascii.decode);
  }

  bool send(String msg) {
    try {
      conn.output.add(Uint8List.fromList(ascii.encode(msg)));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isAvailable() async {
    try {
      await _service.isAvailable;
      debugPrint('isAvailable: true');
      return true;
    } catch (error) {
      debugPrint('isAvailable: false');
      return false;
    }
  }

  Future<bool> isEnabled() async {
    try {
      await _service.isEnabled;
      debugPrint('isEnabled: true');
      return true;
    } catch (error) {
      debugPrint('isEnabled: false');
      return false;
    }
  }

  Future<BluetoothState?> state() async {
    return await _service.state;
  }

  bool requestEnable() {
    bool status = false;

    _service
        .requestEnable()
        .then((value) => status = true)
        .onError((error, stackTrace) => status = false);

    return status;
  }

  bool isConnected() {
    try {
      return _conn.isConnected;
    } catch (e) {
      return false;
    }
  }
}
