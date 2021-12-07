import 'package:flutter/cupertino.dart';
import 'saved_parameters.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
          leading: StreamBuilder<Position>(
              stream: Geolocator.getPositionStream(),
              builder: (context, snapshot) {
                int self_heading = snapshot.data!.heading.toInt();
                return Transform.rotate(
                  angle: 2 * pi * (use_compass ? self_heading : 0) / 360,
                  child: Icon(
                    Icons.arrow_circle_up,
                    size: 35,
                    color: Colors.black26,
                  ),
                );
              }),
          title: const Text('Use your compass'),
          trailing: CupertinoSwitch(
            value: use_compass,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                use_compass = value;
              });
            },
          ),
          onTap: () {
            setState(() {
              use_compass = !use_compass;
            });
          },
        ),
      ),
    );
  }
}
