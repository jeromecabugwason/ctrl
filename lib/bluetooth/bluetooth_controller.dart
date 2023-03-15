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

    void handleConnection() {
      Console.info('connecting...');

      _service.connect().then((value) {
        Console.log('Connected to HC-05 module');
        connectionState = true;
      }).onError((error, stackTrace) {
        connectionState = false;
        Console.error(error.toString());
      });
    }

    void handlePublicScan() {
      // public scan
      // Check if the device is an HC-05 module
      Console.log('Scanning public devices...');

      _service.scan().timeout(const Duration(seconds: 10)).listen(
        (device) {
          Console.log(device.toString());

          if (device.getName == 'HC-05') {
            Console.info('Found HC-05 module in public');
            _service.setDeviceAddress(device.getAddress);
            _service.cancelDiscovery();
            _service.pair('1234');
          }
        },
        onDone: () {
          Console.log('Done Scanning...');
          handleConnection();
        },
        onError: (e) {
          if (e is TimeoutException) {
            Console.info('Scanning timed out. No devices found.');
          } else {
            Console.error(e);
            connectionState = false;
          }
        },
        cancelOnError: true,
      );
    }

    Future<void> handlePairedConnection() async {
      Console.log('Scanning paired devices...');

      final devices = await _service.scanInPairedDevices();
      Device? hc05;

      for (final device in devices) {
        if (device.getName == 'HC-05') {
          Console.log('Found HC-05 module in paired devices');
          hc05 = device;
          break;
        }
      }

      if (hc05 != null) {
        _service.setDeviceAddress(hc05.getAddress);
        handleConnection();
      } else {
        Console.log(
            'Not found in paired devices, proceeding to public scan...');
        handlePublicScan();
      }
    }

    if (!isBluetoothFunctional) {
      Console.log('Bluetooth has some issues, cannot proceed connecting');
    }

    Console.log('Connecting to HC-05 module...');
    await handlePairedConnection();
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
    Console.log(msg);

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
