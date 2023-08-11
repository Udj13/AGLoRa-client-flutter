import 'package:flutter/cupertino.dart';
import '../../utils/compass.dart';
import '../../utils/saved_parameters.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WidgetUseCompass extends StatefulWidget {
  const WidgetUseCompass({
    Key? key,
  }) : super(key: key);

  @override
  State<WidgetUseCompass> createState() => _UseCompassState();
}

class _UseCompassState extends State<WidgetUseCompass> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8),
      child: MergeSemantics(
        child: ListTile(
          leading: StreamBuilder<double>(
              stream: compassDataStream,
              builder: (context, snapshot) {
                double heading = snapshot.data ?? 0;
                return Transform.rotate(
                  angle: -2 * pi * ((useCompass ? heading : 0) + 45) / 360,
                  child: Icon(
                    CupertinoIcons.compass,
                    size: 35,
                    color: Colors.blue,
                  ),
                );
              }),
          title: const Text('Use your compass'),
          trailing: CupertinoSwitch(
            value: useCompass,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                useCompass = value;
                value ? enableCompass() : disableCompass();
              });
            },
          ),
          onTap: () {
            setState(() {
              useCompass = !useCompass;
            });
          },
        ),
      ),
    );
  }
}
