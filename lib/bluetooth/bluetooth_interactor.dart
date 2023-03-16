import 'dart:convert';
import 'dart:typed_data';

import 'package:ctrl/device/device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothInteractor {
  // conn - abbreviation of connection
  final FlutterBluetoothSerial _service;
  late String _deviceAddress;
  //  TODO: invert the dependency
  late BluetoothConnection _conn;

  BluetoothInteractor(this._service);

  Future<List<Device>> scanInPairedDevices() async {
    List<BluetoothDevice> devices = await _service.getBondedDevices();

    return devices
        .map((e) => Device(
              e.name.toString(),
              e.address.toString(),
            ))
        .toList();
  }

  Stream<Device> scan() {
    return _service.startDiscovery().map((e) => Device(
          e.device.name.toString(),
          e.device.address.toString(),
        ));
  }

  Future<void> connect() async {
    try {
      _conn = await BluetoothConnection.toAddress(_deviceAddress);
    } catch (e) {
      throw Exception(
          'Error when connecting to this address: $_deviceAddress, make sure the device is powered on.');
    }
  }

  Future<BluetoothBondState> getBondSate() {
    return _service.getBondStateForAddress(_deviceAddress);
  }

  Future<bool?> pair(String pin) {
    return _service.bondDeviceAtAddress(_deviceAddress, pin: pin);
  }

  Future<void> disconnect() async {
    try {
      await _conn.close();
    } catch (error) {
      throw Exception('Failed to disconnect: ${error.toString()}');
    }
  }

  void send(String msg) {
    if (msg.isEmpty) throw Exception('Message is empty.');

    try {
      _conn.output.add(Uint8List.fromList(ascii.encode(msg)));
    } catch (e) {
      throw Exception('Failed to send message.');
    }
  }

  Future<void> requestEnable() async {
    try {
      await _service.requestEnable();
    } catch (e) {
      throw Exception('Failed to enable Bluetooth: ${e.toString()}');
    }
  }

  void setDeviceAddress(String address) => _deviceAddress = address;

  Future<void> cancelDiscovery() => _service.cancelDiscovery();

  Future<bool> isAvailable() async => await _service.isAvailable ?? false;

  Future<bool> isEnabled() async => await _service.isEnabled ?? false;

  Future<BluetoothState?> state() async => await _service.state;

  Stream<String> startListening() => _conn.input!.map(ascii.decode);

  bool isConnected() {
    try {
      return _conn.isConnected;
    } catch (e) {
      return false;
    }
  }
}
