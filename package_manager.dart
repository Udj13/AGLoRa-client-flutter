import 'package:aglora_client/aglora/parser_point.dart';
import 'package:flutter/foundation.dart';

import '/aglora/parser_info.dart';
import '/aglora/parser_newPoint.dart';
import 'data.dart';
import 'memory.dart';

void packageManager(String package) {
  AGLORATrackerPoint? agloraPoint;

  List<String> fields = package.split('&');

  if (fields[0] == 'info') {
    final String? myId = newInfoParsing(fields);
    if (kDebugMode) print('\nPACKAGE MANAGER: Info received: $myId');
    agloraAppMemory.setIdTo(myId);
  }

  if (fields[0] == 'newpoint') {
    agloraPoint = newPointParsing(fields);
    if (kDebugMode && (agloraPoint?.identifier != null)) {
      print('');
      print('PACKAGE MANAGER: New point from '
          '${agloraPoint?.identifier}');
    }
    agloraAppMemory.addPoint(agloraPoint);
  }

  if (fields[0] == 'point') {
    fields.forEach((field) {
      if (field == 'CRC_ERROR') {
        if (kDebugMode) print('PACKAGE MANAGER: Memory CRC error');
        return;
      }
    });
    agloraPoint = pointParsing(fields);
    if (kDebugMode && (agloraPoint?.identifier != null)) {
      print('');
      print('PACKAGE MANAGER: Saved point from '
          '${agloraPoint?.identifier}');
    }

    agloraAppMemory.addPoint(agloraPoint);
  }
}
