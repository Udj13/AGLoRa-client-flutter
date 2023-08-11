import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../aglora/aglora.dart';
import '../aglora/data.dart';

void startBluetoothListener(BluetoothDevice device) {
  try {
    device.state.listen((status) {
      if (status == BluetoothDeviceState.connected) {
        if (kDebugMode) print('Request history');
        //requestAllTrackers
      }
    });

    device.services.listen((services) {
      BluetoothService? agloraService;
      services.forEach((service) {
        if (service.uuid.toString().startsWith("0000ffa2") ||
            service.uuid.toString().startsWith("0000ffe0")) {
          agloraService = service;
        }
      });

      if (agloraService != null) {
        var characteristics = agloraService!.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString().startsWith("0000ffe1")) {
            c.setNotifyValue(true);
            c.read();

            List<int> request = requestAllTrackers.codeUnits;
            c.write(request, withoutResponse: true);

            c.onValueChangedStream.listen((value) {
              newDataReceiver(value);
            });
          }
        }
      }
    });
  } catch (e) {
    print(e);
  }
}
