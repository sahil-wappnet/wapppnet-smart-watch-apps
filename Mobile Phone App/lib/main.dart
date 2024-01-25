import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:workout/workout.dart';
import 'package:is_wear/is_wear.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wear/wear.dart';
import 'package:http/http.dart' as http;

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

  // var _count = 0;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  // var _context = <String, dynamic>{};
  // var _receivedContexts = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _log = [];
  Map<String, String> fitnessData = {
    'Heart rate': 'N/A',
    'Calories': 'N/A',
    'Steps': 'N/A',
    'Distance': 'N/A',
    'Speed': 'N/A',
  };

  Timer? timer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _watch.messageStream.listen((e) => setState(() {
          fitnessData['Heart rate'] = e['heartRate'].toString();
          fitnessData['Calories'] = e['calories'].toString();
          fitnessData['Steps'] = e['steps'].toString();
          fitnessData['Distance'] = e['distance'].toString();
          fitnessData['Speed'] = e['speed'].toString();
          final requestBody = {
            'Heart rate': e['Heart rate'].toString(),
            'Calories': e['Calories'].toString(),
            'Steps': e['Steps'].toString(),
            'Speed': e['Speed'].toString(),
            'Distance' : e['Distance'].toString(),
            'DateTime': e['Datetime'].toString(),
          };
          // print('$requestBody');
          postData(requestBody);
          _log.add(e);
        }),);
    // _watch.contextStream.listen((e) => setState(() => _log.add('Received context: $e')));
  }

  Future<void> postData(Map<String, dynamic> sentData) async {
    final apiUrl = Uri.parse(
        'https://tbezbjufey323x2fzqhz43nzaq0cpbon.lambda-url.us-west-1.on.aws/',);    

    try {
      final response = await http.post(
        apiUrl,
        body: sentData,
      );

      if (response.statusCode == 200) {
        log('POST request successful');
        log('Response: ${response.body}');
      } else {
        log('POST request failed with status: ${response.statusCode}');
        log('Response: ${response.body}');
      }
    } catch (error) {
      log('Error making POST request: $error');
    }
  }

// Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    // _context = await _watch.applicationContext;
    // _receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final home = Scaffold(
      appBar: AppBar(
        title: Text(
          'Wappnet Smartwatch App',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Card(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width / 2.4,
                      height: 70,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Supported'),
                          const Spacer(),
                          Text(_supported.toString().toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,),),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Card(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width / 2.4,
                      height: 70,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Paired'),
                          const Spacer(),
                          Text(_paired.toString().toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Reachable : '),
                      Text(_reachable.toString().toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,),),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Text('Context: $_context'),
              // Text('Received contexts: $_receivedContexts'),
              ElevatedButton(
                onPressed: initPlatformState,
                child: const Text('Refresh'),
              ),
              const SizedBox(height: 8),
              // const Text('Send'),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: sendMessage,
              //       child: const Text('Message'),
              //     ),
              //     const SizedBox(width: 8),
              //     ElevatedButton(
              //       onPressed: sendContext,
              //       child: const Text('Context'),
              //     ),
              //   ],
              // ),
              // ElevatedButton(
              //   onPressed: toggleBackgroundMessaging,
              //   child: Text(
              //     '${timer == null ? 'Start' : 'Stop'} background messaging',
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              const SizedBox(width: 16),
              // TextButton(
              //   onPressed: _watch.startWatchApp,
              //   child: const Text('Start watch app'),
              // ),
              const SizedBox(width: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Recieived Data'),
                ],
              ),
              ..._log.toList().map((e) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(e['Datetime'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,),),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Calories : ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              e['Calories'],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Heart rate : ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              e['Heart rate'],
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       e['Steps'],
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isWear
          ? AmbientMode(
              builder: (context, mode, child) => child!,
              child: home,
            )
          : home,
    );
  }

  // void sendMessage() {
  //   final message = {'data': 'Hello'};
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
