import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const methodChannel = MethodChannel('samples.flutter.io/battery');
  static const eventChannel = EventChannel('samples.flutter.io/charging');

  int _batteryPercentage = -1;
  String _chargingStatus = 'Unknown';

  @override
  void initState() {
    getData();
    super.initState();
    
  }

  getData()async{
   await getBatteryLevel();
   await getChargingStatus();
  }

  Future<void> getBatteryLevel() async {
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryPercentage = result;
      });
    } on PlatformException catch (e) {
      log("Failed to get battery percentage: '${e.message}'.");
    } finally {
      log("Battery Percentage Working Fine...");
    }
  }

  Future getChargingStatus() async{
    try {
      eventChannel.receiveBroadcastStream().listen((chargingStatus) {
        setState(() {
          _chargingStatus = chargingStatus;
        });

        log("Success in fetching battery ...$chargingStatus");
      });
    } on PlatformException catch (e) {
      log("Failed to get battery status: '${e.message}'.");
    } catch (e) {
      log("Failed to get status: '$e'");
    } 
    finally {
      log("Battery Status Working Fine...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Method and Event Channel',style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const Text(
                  'Battery Level: ',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                  Text(
                  "$_batteryPercentage%",
                  style: const TextStyle(fontSize: 20),
                ),
                ],),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.deepPurple),
                  onPressed: getBatteryLevel,
                  child: const Text("Get Battery Percentage",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Charging Status: ',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                Text(
                  _chargingStatus,
                  style: const TextStyle(fontSize: 20),
                ),
                _chargingStatus == "charging"
                    ? const Icon(
                        Icons.battery_charging_full_outlined,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.battery_alert,
                        color: Colors.red,
                      )
              ],
            )
          ],
        ),
      ),
    );
  }
}
