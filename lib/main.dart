import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
  await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: kDebugMode);
  await Workmanager().registerOneOffTask(
    simpleTaskKey,
    simpleTaskKey, // Ignored on iOS
    initialDelay: Duration(seconds: 2),
    constraints: Constraints(
      // connected or metered mark the task as requiring internet
      networkType: NetworkType.connected,
      // require external power
      requiresCharging: true,
    ),
  );
  Workmanager().registerPeriodicTask(
    simplePeriodicTask,
    simplePeriodicTask,
    initialDelay: Duration(seconds: 10),
  );
  */
  runApp(MyApp());
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

Future<void> callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    await AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'callbackDispatchere',
            body: 'callbackDispatcher'));
    print('register on of task');
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        print("for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }
    print("The iOS background fetch was triggered");
    Directory? tempDir = await getTemporaryDirectory();
    String? tempPath = tempDir.path;
    print("for example Directory.getTemporaryDirectory(): $tempPath");
    for (int i = 0; i < 1000; i++) {
      await Future.delayed(const Duration(seconds: 3));
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: i.toString(),
              body: 'Workmanager '));
      print("Workmanager initialized");
      print("background $i");
    }
    await Future.delayed(const Duration(minutes: 15));
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    /*
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: 'Simple Notification',
              body: 'Simple body'));
    });
    */
  }

  String _batteryLevel = 'Press Button to get battery level';
  final platform = MethodChannel('samples.flutter.io/battery');
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _getBatteryLevel();
          },
          child: Icon(Icons.battery_unknown),
        ),
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Battery %: $_batteryLevel',
                  style: TextStyle(fontSize: 24.0),
                ),
                /*
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () async {
                    await Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                    AwesomeNotifications().createNotification(
                        content: NotificationContent(
                            id: 10,
                            channelKey: 'basic_channel',
                            title: 'Workmanager initialized',
                            body: 'Workmanager initialized'));
                    print("Workmanager initialized");
                  },
                ),
                SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () async {
                    // Workmanager().registerOneOffTask(
                    //   simpleTaskKey,
                    //   simpleTaskKey,
                    //   inputData: <String, dynamic>{
                    //     'int': 1,
                    //     'bool': true,
                    //     'double': 1.0,
                    //     'string': 'string',
                    //     'array': [1, 2, 3],
                    //   },
                    // );
                    try {
                      await Workmanager().registerOneOffTask(
                        simpleTaskKey,
                        simpleTaskKey, // Ignored on iOS
                        initialDelay: Duration(seconds: 2),
                        constraints: Constraints(
                          // connected or metered mark the task as requiring internet
                          networkType: NetworkType.not_required,
                          // require external power
                          requiresCharging: true,
                        ),
                      );
                      AwesomeNotifications().createNotification(
                          content: NotificationContent(
                              id: 10,
                              channelKey: 'basic_channel',
                              title: 'Register OneOff Task',
                              body: 'Register OneOff Task'));
                      print('register on of task');
                    } catch (e) {
                      AwesomeNotifications().createNotification(
                          content: NotificationContent(
                              id: 10,
                              channelKey: 'basic_channel',
                              title: 'r $e',
                              body: e.toString()));
                      print('register on of task');
                    }
                  },
                ),
                // ElevatedButton(
                //   child: Text("Register rescheduled Task"),
                //   onPressed: () {
                //     Workmanager().registerOneOffTask(
                //       rescheduledTaskKey,
                //       rescheduledTaskKey,
                //       inputData: <String, dynamic>{
                //         'key': Random().nextInt(64000),
                //       },
                //     );
                //   },
                // ),
                // ElevatedButton(
                //   child: Text("Register failed Task"),
                //   onPressed: () {
                //     Workmanager().registerOneOffTask(
                //       failedTaskKey,
                //       failedTaskKey,
                //     );
                //   },
                // ),
                // //This task runs once
                // //This wait at least 10 seconds before running
                // ElevatedButton(
                //     child: Text("Register Delayed OneOff Task"),
                //     onPressed: () {
                //       Workmanager().registerOneOffTask(
                //         simpleDelayedTask,
                //         simpleDelayedTask,
                //         initialDelay: Duration(seconds: 10),
                //       );
                //     }),
                // SizedBox(height: 8),
                // //This task runs periodically
                // //It will wait at least 10 seconds before its first launch
                // //Since we have not provided a frequency it will be the default 15 minutes
                ElevatedButton(
                    child: Text("Register Periodic Task (Android)"),
                    onPressed: () {
                      try {
                        Workmanager().registerPeriodicTask(
                          simplePeriodicTask,
                          simplePeriodicTask,
                          initialDelay: Duration(seconds: 10),
                        );
                        AwesomeNotifications().createNotification(
                            content: NotificationContent(
                                id: 10,
                                channelKey: 'basic_channel',
                                title: 'Register Periodic Task (Android)',
                                body: 'Register Periodic Task (Android)'));
                        print('register on of task');
                      } catch (e) {
                        AwesomeNotifications().createNotification(
                            content: NotificationContent(
                                id: 10,
                                channelKey: 'basic_channel',
                                title: e.toString(),
                                body: 'err'));
                        print('register on of task');
                      }
                    }),
                // //This task runs periodically
                // //It will run about every hour
                // ElevatedButton(
                //     child: Text("Register 1 hour Periodic Task (Android)"),
                //     onPressed: Platform.isAndroid
                //         ? () {
                //             Workmanager().registerPeriodicTask(
                //               simplePeriodicTask,
                //               simplePeriodic1HourTask,
                //               frequency: Duration(hours: 1),
                //             );
                //           }
                //         : null),
                // SizedBox(height: 16),
                // Text(
                //   "Task cancellation",
                //   style: Theme.of(context).textTheme.headline5,
                // ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
