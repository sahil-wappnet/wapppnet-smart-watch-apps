import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:is_wear/is_wear.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';
import 'package:intl/intl.dart';

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
  final workout = Workout();

  final exerciseType = ExerciseType.walking;
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

  var _count = 0;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  Timer? timer;

  @override
  void initState() {
    super.initState();

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

    _watch.messageStream
        .listen((e) => setState(() => _log.add('Received message: $e')));

    _watch.contextStream.listen((e) => setState(() => _log.add('Received context: $e')));
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    _context = await _watch.applicationContext;
    _receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final home = Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Heart rate: $heartRate'),
                Text('Calories: ${calories.toStringAsFixed(2)}'),
                Text('Steps: $steps'),
                Text('Distance: ${distance.toStringAsFixed(2)}'),
                Text('Speed: ${speed.toStringAsFixed(2)}'),
                // Text('Supported: $_supported'),
                // Text('Paired: $_paired'),
                // Text('Reachable: $_reachable'),
                // Text('Context: $_context'),
                // Text('Received contexts: $_receivedContexts'),
                // TextButton(
                //   onPressed: initPlatformState,
                //   child: const Text('Refresh'),
                // ),
                // const SizedBox(height: 8),
                // const Text('Send'),
                TextButton(
                  onPressed: toggleExerciseState,
                  child: Text(started ? 'Stop' : 'Start'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: sendMessage,
                      child: const Text('Send Data'),
                    ),
                    // const SizedBox(width: 8),
                    // TextButton(
                    //   onPressed: sendContext,
                    //   child: const Text('Context'),
                    // ),
                  ],
                ),
                // TextButton(
                //   onPressed: toggleBackgroundMessaging,
                //   child: Text(
                //     '${timer == null ? 'Start' : 'Stop'} background messaging',
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                // const SizedBox(width: 16),
                // TextButton(
                //   onPressed: _watch.startWatchApp,
                //   child: const Text('Start watch app'),
                // ),
                const SizedBox(width: 16),
                // const Text('Log'),
                // ..._log.reversed.map(Text.new),
              ],
            ),
          ),
        ),
      ),
    );

    return MaterialApp(
      home: isWear
          ? AmbientMode(
              builder: (context, mode, child) => child!,
              child: home,
            )
          : home,
    );
  }

  void toggleExerciseState() async {
    setState(() {
      started = !started;
    });

    if (started) {
      final supportedExerciseTypes = await workout.getSupportedExerciseTypes();
      log('Supported exercise types: ${supportedExerciseTypes.length}');

      final result = await workout.start(
        // In a real application, check the supported exercise types first
        exerciseType: exerciseType,
        features: features,
        enableGps: enableGps,
      );

      if (result.unsupportedFeatures.isNotEmpty) {
        // ignore: avoid_print
        print('Unsupported features: ${result.unsupportedFeatures}');
        // In a real application, update the UI to match
      } else {
        // ignore: avoid_print
        print('All requested features supported');
      }
    } else {
      await workout.stop();
    }
  }

  void sendMessage() {
    final  currentTime = DateFormat('E, d MMM yyyy, h:mm:ss a').format(DateTime.now());
    final message = {'Heart rate': heartRate.toStringAsFixed(1),'Calories':calories.toStringAsFixed(1),'Steps':steps.toStringAsFixed(0),'Distance':distance.toStringAsFixed(1),'Speed':speed.toStringAsFixed(1),'Datetime': currentTime};
    _watch.sendMessage(message);
    setState(() => _log.add('Sent message: $message'));
  }

  void sendContext() {
    _count++;
    final context = {'data': _count};
    _watch.updateApplicationContext(context);
    setState(() => _log.add('Sent context: $context'));
  }

  void toggleBackgroundMessaging() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }
}
