import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Text(
        result.device.name,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text('noname device');
    }
  }

  Icon getIconsFromRSSI(int rssi) {
    if (rssi >= -80) return Icon(Icons.signal_cellular_null);
    if (rssi >= -70) return Icon(Icons.signal_cellular_4_bar);
    return Icon(Icons.network_cell_outlined);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      leading: getIconsFromRSSI(result.rssi),
      trailing: ElevatedButton(
        child: Text('Connect'),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
    );
  }
}
