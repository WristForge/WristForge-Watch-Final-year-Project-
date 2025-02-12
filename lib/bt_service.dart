import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class BluetoothService {
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  Function(int)? onStepCountReceived;

  Future<void> requestBluetoothPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }
  }

  Future<void> scanAndConnect() async {
    await requestBluetoothPermissions(); // Ensure Permissions Before Scanning
    List<BluetoothDevice> devices = [];

    // Get bonded (paired) devices
    bluetooth.getBondedDevices().then((bondedDevices) {
      devices = bondedDevices;
      for (var device in devices) {
        if (device.name == "HC-05") {
          // Change to your smartwatch's Bluetooth name
          _connectToDevice(device);
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');

      connection!.input!.listen((data) {
        _handleData(data);
      }).onDone(() {
        print('Disconnected from device');
      });
    } catch (error) {
      print('Connection error: $error');
    }
  }

  void _handleData(Uint8List data) {
    if (data.isNotEmpty) {
      int stepCount = data[0]; // Modify based on your data format
      if (onStepCountReceived != null) {
        onStepCountReceived!(stepCount);
      }
    }
  }

  void disconnect() {
    connection?.finish();
  }
}
