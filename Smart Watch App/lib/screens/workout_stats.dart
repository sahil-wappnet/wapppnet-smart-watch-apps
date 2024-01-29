// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:watch_connectivity_example/widgets/detail_tile.dart';
import 'package:workout/workout.dart';

class WorkoutStats extends StatefulWidget {
  final ExerciseType? exerciseType;
  final String? exerciseTitle;
  final Position? currentPosition;
  final DateTime? currentTime;
  const WorkoutStats({
    Key? key,
    required this.exerciseType,
    required this.exerciseTitle,
    required this.currentPosition,
    required this.currentTime,
  }) : super(key: key);

  @override
  State<WorkoutStats> createState() => _WorkoutStatsState();
}

class _WorkoutStatsState extends State<WorkoutStats> {
  double? latitude;
  double? longitude;

  final workout = Workout();

  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];
  final enableGps = true;

  double heartRate = 0;
  double calories = 0;
  double steps = 0;
  double distance = 0;
  double speed = 0;
  bool started = false;

  final _watch = WatchConnectivity();

  var supported = false;
  var paired = false;
  var reachable = false;
  var contextValue = <String, dynamic>{};
  var receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  Timer? timer;
  
  bool isTimerRunning = false;
  int secondsElapsed = 0;

  void startTimer() {
    setState(() {
      isTimerRunning = true;
    });

    // Timer runs every second
    if (isTimerRunning == true) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (isTimerRunning == true) {
            secondsElapsed =
                DateTime.now().difference(widget.currentTime!).inSeconds;            
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    secondsElapsed = 0;
    startTimer();
    workout.stream.listen((event) {
      log('${event.feature}: ${event.value} (${event.timestamp})');
      switch (event.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = event.value;
          });
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = event.value;
          });
          break;
        case WorkoutFeature.steps:
          setState(() {
            steps = event.value;
          });
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = event.value;
          });
          break;
        case WorkoutFeature.speed:
          setState(() {
            speed = event.value;
          });
          break;
      }
    });
    startLocationUpdates();
    toggleExerciseState();
    // _watch.messageStream
    //     .listen((e) => setState(() => _log.add('Received message: $e')));

    // _watch.contextStream
    //     .listen((e) => setState(() => _log.add('Received context: $e')));
    initPlatformState();
  }

  void initPlatformState() async {
    supported = await _watch.isSupported;
    paired = await _watch.isPaired;
    reachable = await _watch.isReachable;
    contextValue = await _watch.applicationContext;
    receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  void startLocationUpdates() {
    if (isTimerRunning == true) {
      const duration = Duration(seconds: 1);
      Timer.periodic(duration, (timer) {
        if(isTimerRunning == true){
          getCurrentLocation();
        }        
      });
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    // Format the time as mm:ss
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              Text(
                '${widget.exerciseTitle}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              // Text(
              //   formatTime(secondsElapsed),
              //   style: const TextStyle(fontSize: 14),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Detailtile(
                    icon: const Icon(
                      Icons.favorite_outlined,
                      color: Colors.red,
                    ),
                    value: '$heartRate bpm',
                    valueColor: Colors.white,
                  ),
                  Detailtile(
                    icon: const Icon(Icons.electric_bolt, color: Colors.amber),
                    value: '${calories.toStringAsFixed(1)} Kcal',
                    valueColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Detailtile(
                    icon: const Icon(Icons.speed, color: Colors.lightBlue),
                    value: '$speed km/h',
                    valueColor: Colors.white,
                  ),
                  Detailtile(
                    icon: const Icon(
                      Icons.timer,
                      color: Colors.green,
                    ),
                    value: formatTime(secondsElapsed),
                    valueColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${latitude ?? "N/A"} Lat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${longitude ?? "N/A"} Lon',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              ElevatedButton(
                onPressed: toggleExerciseState,
                child: Text(started ? 'End Workout' : 'Start'),
              ),

              // ElevatedButton(
              //   onPressed: getCurrentLocation,
              //   child: const Text('Get Location'),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      log('Location permission granted');
    } else if (status.isDenied) {
      // Permission is denied
      // You can display a dialog to inform the user and ask them to grant the permission
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please grant location permission to use this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied
      // The user has chosen to never ask for this permission again
      // You can ask the user to manually enable the permission in the settings
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please enable location permission in the app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    requestLocationPermission();

    try {
      final position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      log('Lat: $latitude & Long : $longitude time: ${position.timestamp}');
    } catch (e) {
      log('$e');
    }
  }

  void toggleExerciseState() async {
    setState(() {
      started = !started;
    });
    log('Value : $started');

    if (started == true) {
      startTimer();
      final supportedExerciseTypes = await workout.getSupportedExerciseTypes();
      log('Supported exercise types: ${supportedExerciseTypes.length}');

      final result = await workout.start(
        exerciseType: widget.exerciseType!,
        features: features,
        enableGps: enableGps,
      );

      if (result.unsupportedFeatures.isNotEmpty) {
        log('Unsupported features: ${result.unsupportedFeatures}');
      } else {
        log('All requested features supported');
      }
    } else {
      log('Current Value is : $started');
      await workout.stop();
      setState(() {
        isTimerRunning = false;
      });
      sendMessage();
      Navigator.pop(context);
      timer!.cancel();
    }
  }

  void sendMessage() {
    final currentTime =
        DateFormat('E, d MMM yyyy, h:mm:ss a').format(DateTime.now());
    final message = {
      'Starting Latitude': widget.currentPosition!.latitude,
      'Starting Longitude': widget.currentPosition!.longitude,
      'Heart rate': heartRate.toStringAsFixed(1),
      'Calories': calories.toStringAsFixed(1),
      'Steps': steps.toStringAsFixed(0),
      'Distance': distance.toStringAsFixed(1),
      'Speed': speed.toStringAsFixed(1),
      'Ending Latitude': latitude,
      'Ending Longitude' : longitude, 
      'Duration': formatTime(secondsElapsed),
      'Datetime': currentTime,
      'Exercise': widget.exerciseTitle
    };
    _watch.sendMessage(message);
    setState(() => _log.add('Sent message: $message'));
  }
}
