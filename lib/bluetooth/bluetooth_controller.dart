import 'dart:async';

import 'package:ctrl/bluetooth/bluetooth_interactor.dart';
import 'package:ctrl/device/device.dart';
import 'package:ctrl/stream/console/console.dart';

class BluetoothController {
  final BluetoothInteractor _service;

  BluetoothController(this._service);

  Future<bool> connect() async {
    bool connectionState = false;

    final bool isBluetoothFunctional = await checkBluetooth();

    if (!isBluetoothFunctional) {
      Console.log('Bluetooth has some issues, cannot proceed connecting');
      connectionState = false;
    }

    // for paired devices
    List<Device> devices = await _service.scanInPairedDevices();

    for (Device device in devices) {
      if (device.getName == 'HC-05') {
        Console.log('Found HC-05 module in paired devices');
        _service.setDeviceAddress(device.getAddress);
      }
    }

    // public scan
    // Check if the device is an HC-05 module
    StreamSubscription<Device> streamSub = _service.scan().listen((e) async {
      if (e.getName == 'HC-05') {
        _service.setDeviceAddress(e.getAddress);

        Console.log('Found HC-05 module in public, pairing..');
        _service.pair('1234');

        await _service.cancelDiscovery();
      } else {
        throw Exception(
            'No HC-05 devices detected, make sure the device is powered on.');
      }
    });

    streamSub.onData((data) => Console.log(data.toString()));

    streamSub.onError((e) {
      Console.error(e);
      connectionState = false;
    });

    streamSub.onDone(() {
      _service.connect().then((value) {
        Console.log('Connected to HC-05 module');
        connectionState = true;
      }).onError((error, stackTrace) {
        connectionState = false;
        Console.error(error.toString());
      });
    });

    return connectionState;
  }

  Future<bool> startListening() async {
    Stream<String> stream = _service.startListening();
    Console.log('Started listening for incoming messages');

    await for (var message in stream) {
      Console.log('Received data: $message');
      return true;
    }

    return false;
  }

  bool send(String msg) {
    bool isSuccess = _service.send(msg);

    if (isSuccess) {
      Console.log('Message Sent!');
    } else {
      Console.log('Message not sent, try again later.');
    }

    return isSuccess;
  }

  bool disconnect() {
    bool isSuccess = _service.disconnect();

    if (isSuccess) {
      Console.log('Disconnected!');
    } else {
      Console.log('Not Disconnected, try again later.');
    }

    return isSuccess;
  }

  bool checkConnection() {
    bool isConnected = _service.isConnected();

    if (isConnected) {
      Console.log('Bluetooth device is connected.');
    } else {
      Console.log('Bluetooth device is not connected.');
    }

    return isConnected;
  }

  Future<bool> checkBluetooth() async {
    final isAvailable = await _service.isAvailable();
    final isEnabled = await _service.isEnabled();

    Console.log('bluetooth is available: $isAvailable');
    Console.log('bluetooth is enabled: $isEnabled');

    if (isEnabled && isAvailable) {
      return true;
    } else {
      // request permissions
      return _service.requestEnable();
    }
  }
}
