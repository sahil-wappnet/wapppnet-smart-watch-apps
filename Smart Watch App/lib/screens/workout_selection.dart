// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watch_connectivity_example/screens/workout_stats.dart';
import 'package:watch_connectivity_example/utils/constants.dart';

class WorkoutSelectionScreen extends StatefulWidget {
  const WorkoutSelectionScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  Position? currentPosition;
  double? latitude;
  double? longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              const Text(
                'Select Workout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listOfWorkouts.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      // elevation: 2,
                      color: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                getCurrentLocationofWorkout();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkoutStats(
                                              exerciseType:
                                                  listOfWorkouts[index].workOutType,
                                              exerciseTitle: listOfWorkouts[index]
                                                  .workOutTitle,
                                              currentPosition: currentPosition,
                                              currentTime: DateTime.now(),
                                            ),),);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${listOfWorkouts[index].workOutTitle}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const Divider(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  void requestLocationPermission()async {
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
          content: const Text('Please grant location permission to use this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:const Text('OK'),
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
          content: const Text('Please enable location permission in the app settings.'),
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
  

  Future<void> getCurrentLocationofWorkout() async {
    if (kDebugMode) {
      log('loc called');
    }
    requestLocationPermission();

    try {
      if (kDebugMode) {
        log('try called');
      }

      currentPosition = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kDebugMode) {
        log('position called');
      }

      setState(() {
        latitude = currentPosition!.latitude;
        longitude = currentPosition!.longitude;
      });

      if (kDebugMode) {
        log('Latitude: $latitude & Longitude : $longitude');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
