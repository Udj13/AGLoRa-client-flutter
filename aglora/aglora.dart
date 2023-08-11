import 'dart:core'; //https://api.flutter.dev/flutter/dart-core/DateTime-class.html

import 'package:aglora_client/aglora/package_manager.dart';
import 'package:flutter/foundation.dart';

import '/aglora/package_finder.dart';

/*
Workflow:
1. Add new date to stack
2. Find packets is stack
3. Check packet`s type and parsing
 */

String _bleDataStack = '';

const maxStackLength = 520; // stack, bytes, all size

String _blePreviousData = '';

int countOfTrackers = 0;
int headerEndIndex = 0;

void newDataReceiver(List<int> value) {
  String newData = '';

  try {
    newData = String.fromCharCodes(value);
  } catch (e) {
    if (kDebugMode) print('Error in aglora.dart: String.fromCharCodes');
  }

  if (kDebugMode) print('New BLE received: $newData');

  if (_bleDataStack.length > maxStackLength) {
    print(
        'Need to cut string, _bleDataStack = ${_bleDataStack.length}, maxStackLength = $maxStackLength');
    _bleDataStack.substring(
        _bleDataStack.length - maxStackLength - 1, _bleDataStack.length - 1);
    if (kDebugMode) {
      print('Stack is cut to ${_bleDataStack.length} characters');
    }
  }

  // check for duplicates
  if (_blePreviousData != newData) {
    _bleDataStack = _bleDataStack + newData;
    _blePreviousData = newData;
    print('Stack:\n$_bleDataStack');
  }

  String stackAfterProcessing = '';

  if (kDebugMode) {
    //   print('BLE: Stack:\n$_bleDataStack');
  }

  List<String> package = [];
  (package, stackAfterProcessing) = packageFindIn(stack: _bleDataStack);

  if (kDebugMode) {
    print('');
    print('BLE: Stack after processing:\n'
        '$stackAfterProcessing');
    print('BLE: Found ${package.length} packages');
  }
  _bleDataStack = stackAfterProcessing;

  package.forEach((nextPackage) {
    print('');
    print(' ---------------\nBLE: next package ');
    print(nextPackage);
    packageManager(nextPackage);
  });
}
