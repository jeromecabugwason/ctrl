import 'dart:convert';
import 'dart:typed_data';

import 'package:ctrl/device/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothInteractor {
  // conn - abbreviation of connection
  final FlutterBluetoothSerial _service;
  late String _deviceAddress;
  late BluetoothConnection _conn;

  BluetoothInteractor(this._service);

  void setDeviceAddress(String address) {
    _deviceAddress = address;
  }

  Future<void> cancelDiscovery() {
    return _service.cancelDiscovery();
  }

  Future<List<Device>> scanInPairedDevices() async {
    List<BluetoothDevice> devices = await _service.getBondedDevices();

    return devices
        .map((e) => Device(e.name.toString(), e.address.toString()))
        .toList();
  }

  Stream<Device> scan() {
    return _service.startDiscovery().map(
        (e) => Device(e.device.name.toString(), e.device.address.toString()));
  }

  Future<void> connect() async {
    try {
      _conn = await BluetoothConnection.toAddress(_deviceAddress);
    } catch (e) {
      throw Exception(
          'Something went wrong when connecting to this address: $_deviceAddress');
    }
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
    return _conn.input!.map(ascii.decode);
  }

  bool send(String msg) {
    try {
      _conn.output.add(Uint8List.fromList(ascii.encode(msg)));
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
