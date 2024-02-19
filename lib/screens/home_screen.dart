import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
 static const platform = MethodChannel('samples.flutter.dev/battery');

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result =
          await MyHomePage.platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result %';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: ${e.message}";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true, title: const Text("Method Channel Demo",style: TextStyle(color: Colors.white),),),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text('Get Battery Percentage'),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(_batteryLevel),
            ],
          ),
        ),
      ),
    );
  }
}
