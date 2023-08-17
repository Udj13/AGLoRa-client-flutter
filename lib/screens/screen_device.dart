import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../aglora/data.dart';
import '../utils/saved_parameters.dart';
import 'widgets/widget_lora_tracker_tile.dart';
import 'widgets/widget_use_compass.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  Widget _buildTrackersTiles(List<AGLORATrackerPoint> _trackersDataList) {
    return Column(
      children: _trackersDataList
          .map((e) => LORAtrackerTile(
              time: e.time,
              lat: e.latitude,
              lon: e.longitude,
              identifier: e.identifier,
              sensors: e.sensors,
              useCompass: useCompass))
          .toList(),
    );
    //return Text('Not AGLORA data.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connecting:
                    text = 'waiting...';
                    break;
                  case BluetoothDeviceState.disconnecting:
                    text = 'disconnecting...';
                    break;
                  case BluetoothDeviceState.connected:
                    onPressed = () => device.disconnect();
                    text = 'Disconnect';
                    device.discoverServices();
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () => device.connect();
                    text = 'Connect';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return Row(
                  children: [
                    OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        )),
                    SizedBox(width: 10),
                    bluetoothStatusIcon(device: device),
                    SizedBox(width: 10),
                  ],
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<AGLORATrackerPoint>>(
                stream: trackersListStream,
                initialData: [],
                builder: (c, snapshot) {
                  return _buildTrackersTiles(snapshot.data!);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: WidgetUseCompass(),
        ));
  }
}

class discoveringServicesIcon extends StatelessWidget {
  const discoveringServicesIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: device.isDiscoveringServices,
      initialData: false,
      builder: (c, snapshot) => IndexedStack(
        index: snapshot.data! ? 1 : 0,
        children: <Widget>[
          Icon(Icons.account_tree),
          SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
        ],
      ),
    );
  }
}

class bluetoothStatusIcon extends StatelessWidget {
  const bluetoothStatusIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: device.state,
      initialData: BluetoothDeviceState.connecting,
      builder: (c, snapshot) =>
          (snapshot.data == BluetoothDeviceState.connected)
              ? Icon(CupertinoIcons.bluetooth,
                  color: Colors.lightGreenAccent.shade100)
              : Icon(Icons.bluetooth_disabled, color: Colors.redAccent),
    );
  }
}
