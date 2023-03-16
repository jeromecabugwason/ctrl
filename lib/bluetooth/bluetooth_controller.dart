import 'dart:async';

import 'package:ctrl/bluetooth/bluetooth_interactor.dart';
import 'package:ctrl/device/device.dart';
import 'package:ctrl/state/bool_state.dart';
import 'package:ctrl/stream/console/console.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  final BluetoothInteractor _service;
  BoolState scanState = BoolState();

  BluetoothController(this._service);

  void _handlePairing(Device device) {
    _service.setDeviceAddress(device.getAddress);
    _service.pair('1234');
  }

  Future<bool> _handleConnection(Device device) async {
    Console.info('connecting...');

    _service.setDeviceAddress(device.getAddress);

    try {
      await _service.connect();
      Console.log('Connected to HC-05 module');
      return true;
    } catch (error) {
      Console.error(error.toString());
      return false;
    }
  }

  Device _getDeviceFromList(List<Device> devices) {
    return devices.firstWhere((device) => device.getName == 'HC-05');
  }

  Device _getDeviceFromStream() {
    late Device device;

    _service
        .scan()
        .timeout(
          const Duration(seconds: 10),
        )
        .listen(
      (publicDevice) {
        Console.log(publicDevice.toString());

        if (publicDevice.getName == 'HC-05') {
          device = publicDevice;
          _service.cancelDiscovery();
        }
      },
      onError: (e) => Console.error(e.toString()),
    );

    return device;
  }

  Future<void> _handlePairedConnection() async {
    Console.log('Scanning paired devices...');

    final List<Device> devices = await _service.scanInPairedDevices();

    try {
      Device device = _getDeviceFromList(devices);
      Console.log('Found in paired devices.');
      await _handleConnection(device);
    } catch (e) {
      Console.error('Not found in paired devices.');
      rethrow;
    }
  }

  Future<void> _handlePublicScan() async {
    Console.log('Scanning public devices...');

    try {
      //  get device stream
      Device device = _getDeviceFromStream();

      Console.info('Found device in public');

      _handlePairing(device);
    } catch (error) {
      Console.error('Failed paired connection ${error.toString()}');
    }
  }

  Future<void> connect() async {
    if (scanState.isEnabled) return Console.log('Already scanning');

    bool isBluetoothEnabled = await checkBluetooth();

    if (scanState.isDisabled && isBluetoothEnabled) {
      Console.log('Running bluetooth search job...');
      scanState.enable();

      try {
        await _handlePairedConnection();
      } catch (e) {
        await _handlePublicScan();
      } finally {
        scanState.disable();
      }
    }
  }

  void startListening() async {
    Console.log('Started listening for incoming data stream');

    _service.startListening().listen((data) {
      Console.log('Received data: $data');
    });
  }

  void send(String msg) {
    try {
      _service.send(msg);
      Console.log(msg);
    } catch (e) {
      Console.error(e.toString());
    }
  }

  void disconnect() {
    try {
      _service.disconnect();
      Console.log('Disconnected!');
    } catch (e) {
      Console.error(e.toString());
    }
  }

  bool checkConnection() {
    try {
      bool status = _service.isConnected();
      Console.log(
          'Bluetooth device connection: ${status ? 'connected' : 'disconnected'}');

      return status;
    } catch (e) {
      Console.error(e.toString());
      return false;
    }
  }

  Future<bool> checkBluetooth() async {
    final isAvailable = await _service.isAvailable();
    final isEnabled = await _service.isEnabled();
    final canEnable = isEnabled && isAvailable;

    Console.log('bluetooth is available: $isAvailable');
    Console.log('bluetooth is enabled: $isEnabled');

    try {
      if (!canEnable) await enableBluetooth();
      return true;
    } catch (e) {
      Console.error(e.toString());
      return false;
    }
  }

  Future<Map<Permission, PermissionStatus>> checkPermissions() async {
    return await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> enableBluetooth() async {
    await checkPermissions();
    bool isPermitted = await Permission.bluetooth.isGranted;

    if (isPermitted) return await _service.requestEnable();
    return Future.error('is granted?: $isPermitted');
  }
}
