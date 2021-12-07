import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'screen_device.dart';

class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile({Key? key, required this.d}) : super(key: key);

  final BluetoothDevice d;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.gps_fixed,
      ),
      title: Text(d.name),
      subtitle: Text('device connected'),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: d.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          if (snapshot.data == BluetoothDeviceState.connected) {
            return ElevatedButton(
              child: Text('OPEN'),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                d.discoverServices();
                return DeviceScreen(device: d);
              })),
            );
          }
          return Text(snapshot.data.toString());
        },
      ),
    );
  }
}
