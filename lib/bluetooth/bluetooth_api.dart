import 'package:ctrl/bluetooth/bluetooth_controller.dart';
import 'package:ctrl/bluetooth/bluetooth_interactor.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothApi {
  FlutterBluetoothSerial get _getSerial => FlutterBluetoothSerial.instance;
  BluetoothInteractor get _getInteractor => BluetoothInteractor(_getSerial);
  BluetoothController get getController => BluetoothController(_getInteractor);
}
