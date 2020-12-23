import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer_google/SimpleStepDetector.dart';
import 'package:pedometer_google/StepListener.dart';
import 'package:sensors/sensors.dart';
// import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements StepListener {
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  String _platform;
  bool isIOS = false;
  SimpleStepDetector simpleStepDetector;

  int numSteps = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedometer Example'),
      ),
      body: FutureBuilder(
        future: deviceInfo(),
        builder: (context, snap) => !snap.hasData
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                    child: Text('STEPS: $numSteps'),
                  ),
                  Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Accelerometer: $accelerometer'),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                  ),
                  Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('UserAccelerometer: $userAccelerometer'),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                  ),
                  Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Gyroscope: $gyroscope'),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                  ),
                ],
              ),
      ),
    );
  }

  deviceInfo() async {
    //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    //   return androidInfo.id;
    try {
      if (Platform.isIOS) {
        _platform = 'ios';
        isIOS = true;
        return true;
      } else {
        _platform = 'android';
        print('é android');
        return true;
      }
    } on PlatformException {
      print('erro');
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });

      int time = (DateTime.now().microsecond * 1000); //microseconds*1000

      double x = event.x;
      double y = event.y;
      double z = event.z;

      print('Time: $time, x: $x, y: $y, z: $z');
      simpleStepDetector.updateAccel(time, x, y, z, isIOS);
    }));

    simpleStepDetector = new SimpleStepDetector();
    simpleStepDetector.registerListener(this);
  }

  @override
  void step(int timeNs) {
    print('Entrou!');
    setState(() {
      numSteps++;
    });
  }
}
