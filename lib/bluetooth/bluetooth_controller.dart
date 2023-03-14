import 'package:ctrl/bluetooth/bluetooth_interactor.dart';
import 'package:flutter/material.dart';

class BluetoothController {
  final BluetoothInteractor _service;

  BluetoothController(this._service);

  Future<String> connect() async {
    bool isInPairedDevices = false;
    bool isNotInPairedDevices = false;

    bool isBluetoothFunctional = await checkBluetooth();

    if (!isBluetoothFunctional) {
      return 'Bluetooth has some issues, cannot proceed connecting';
    }

    isInPairedDevices = _service.scanInPairedDevices();
    isNotInPairedDevices = _service.scan();

    if (isInPairedDevices) {
      return 'Found HC-05 module in paired devices';
    }

    if (isNotInPairedDevices) {
      return 'Found HC-05 module in public, pairing..';
    }

    if (isInPairedDevices) {
      _service.connect();
    }

    if (isNotInPairedDevices) {
      _service.pair('1234');
      _service.connect();
    }

    return 'No HC-05 devices detected, make sure the device is powered on.';
  }

  Stream<String> listen() {
    return _service.startListening();
  }

  String send(String msg) {
    bool isSuccess = _service.send(msg);

    if (isSuccess) {
      return 'Message Sent!';
    } else {
      return 'Message not sent, try  again later.';
    }
  }

  String disconnect() {
    bool isSuccess = _service.disconnect();

    if (isSuccess) {
      return 'Disconnected!';
    } else {
      return 'Not Disconnected, try  again later.';
    }
  }

  bool isConnected() {
    return _service.isConnected();
  }

  Future<bool> checkBluetooth() async {
    bool isAvailable = await _service.isAvailable();
    bool isEnabled = await _service.isEnabled();

    debugPrint('bluetooth is available: $isAvailable');
    debugPrint('bluetooth is enabled: $isEnabled');

    if (isEnabled && isAvailable) {
      return true;
    } else {
      // request permissions
      return _service.requestEnable();
    }
  }

  bool checkConnection() {
    return _service.isConnected();
  }
}
