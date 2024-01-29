import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:is_wear/is_wear.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:watch_connectivity_example/screens/workout_selection.dart';
import 'package:wear/wear.dart';

late final bool isWear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isWear = (await IsWear().check()) ?? false;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  final _watch = WatchConnectivity();
  var supported = false;
  var paired = false;
  var reachable = false;
  var contextValue = <String, dynamic>{};
  var receivedContexts = <Map<String, dynamic>>[];
  

  @override
  void initState() {
    super.initState();  
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

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isWear
          ? WatchShape(
              builder: (context, shape, child) {
                log('Watch Shape is $shape');
                return AmbientMode(
                  builder: (context, mode, child) {
                    log('Model $mode');
                    return child!;
                  },
                  child: const WorkoutSelectionScreen(),
                );
              },
            )
          : const WorkoutSelectionScreen(),
    );
  }

  

  // void toggleExerciseState() async {
  //   setState(() {
  //     started = !started;
  //   });
  //   log('Value : $started');

  //   if (started) {
  //     final supportedExerciseTypes = await workout.getSupportedExerciseTypes();
  //     log('Supported exercise types: ${supportedExerciseTypes.length}');

  //     final result = await workout.start(
  //       exerciseType: exerciseType,
  //       features: features,
  //       enableGps: enableGps,
  //     );

  //     if (result.unsupportedFeatures.isNotEmpty) {
  //       log('Unsupported features: ${result.unsupportedFeatures}');
  //     } else {
  //       log('All requested features supported');
  //     }
  //   } else {
  //     await workout.stop();
  //   }
  // }

  // void sendMessage() {
  //   final currentTime =
  //       DateFormat('E, d MMM yyyy, h:mm:ss a').format(DateTime.now());
  //   final message = {
  //     'Heart rate': heartRate.toStringAsFixed(1),
  //     'Calories': calories.toStringAsFixed(1),
  //     'Steps': steps.toStringAsFixed(0),
  //     'Distance': distance.toStringAsFixed(1),
  //     'Speed': speed.toStringAsFixed(1),
  //     'Datetime': currentTime
  //   };
  //   _watch.sendMessage(message);
  //   setState(() => _log.add('Sent message: $message'));
  // }

  // void sendContext() {
  //   _count++;
  //   final context = {'data': _count};
  //   _watch.updateApplicationContext(context);
  //   setState(() => _log.add('Sent context: $context'));
  // }

  // void toggleBackgroundMessaging() {
  //   if (timer == null) {
  //     timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
  //   } else {
  //     timer?.cancel();
  //     timer = null;
  //   }
  //   setState(() {});
  // }
}
