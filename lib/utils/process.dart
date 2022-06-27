// import 'dart:async';
//
// import 'package:flutter/material.dart' hide MenuItem;
// import 'dart:io';
// import 'package:process_run/shell.dart';
// //import 'package:test_desktop/utils/string_utils.dart';
// import 'package:window_manager/window_manager.dart';
// import 'package:tray_manager/tray_manager.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await windowManager.ensureInitialized();
//
//   WindowOptions windowOptions = const WindowOptions(
//     size: Size(800, 600),
//     center: true,
//     backgroundColor: Colors.transparent,
//     skipTaskbar: false,
//     titleBarStyle: TitleBarStyle.normal,
//   );
//   await windowManager.hide();
//   windowManager.waitUntilReadyToShow(windowOptions, () async {
//     await windowManager.show();
//     await windowManager.focus();
//   });
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> with WindowListener, TrayListener {
//   int _counter = 0;
//   String cpuLoad = '';
//   String memUsed = '';
//   String memFreePercents = '';
//
//   late Process cpuProc;
//   late Process xinputProc;
//
//   late StreamController<String> cpuStreamController;
//   late StreamController<List<String>> memStreamController;
//   late StreamController<String> keyboardStreamController;
//   late StreamController<String> mouseStreamController;
//
//   late Stream<String> cpuStream;
//   late Stream<List<String>> memStream;
//   late Stream<String> keyboardStream;
//   late Stream<String> mouseStream;
//
//   @override
//   void initState() {
//     windowManager.addListener(this);
//     trayManager.addListener(this);
//
//     cpuStreamController = StreamController();
//     memStreamController = StreamController();
//     keyboardStreamController = StreamController();
//     mouseStreamController = StreamController();
//
//     cpuStream = cpuStreamController.stream;
//     memStream = memStreamController.stream;
//     keyboardStream = keyboardStreamController.stream;
//     mouseStream = mouseStreamController.stream;
//
//     _init();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     windowManager.removeListener(this);
//     trayManager.removeListener(this);
//     super.dispose();
//   }
//
//   void _init() async {
//     await windowManager.setPreventClose(true);
//     await initSystemTray();
//
//     // cpuProc = await Process.start('mpstat', ['1']);
//
//     // cpuProc.outLines.forEach((value) async {
//     //   var cpu = num.tryParse((value.split(' ').last.replaceAll(',', '.')));
//     //   if (cpu != null) {
//     //     var cpuLoad = 'CPU load: ${(100 - cpu).toStringAsFixed(2)}%';
//     //     cpuStreamController.add(cpuLoad);
//     //
//     //     var memProc = await Process.run('cat', ['/proc/meminfo']);
//     //     var memTotalRaw = int.parse(StringUtils.removeLongSpaces(memProc.outLines.firstWhere((element) => element.contains('MemTotal'))).split(' ')[1]);
//     //     var memFreeRaw = int.parse(StringUtils.removeLongSpaces(memProc.outLines.firstWhere((element) => element.contains('MemFree'))).split(' ')[1]);
//     //     var memUsedRaw = memTotalRaw - memFreeRaw;
//     //     memFreePercents = (100 / (memTotalRaw / memFreeRaw)).toStringAsFixed(1);
//     //
//     //     if (memUsedRaw > 1000000) {
//     //       memUsed = '${(memUsedRaw / 1000000).toStringAsFixed(2)} Gb';
//     //     } else if (memUsedRaw < 1000000 && memUsedRaw > 1000) {
//     //       memUsed = '${(memUsedRaw / 1000).toStringAsFixed(2)} Mb';
//     //     } else {
//     //       memUsed = '$memUsedRaw Kb';
//     //     }
//     //
//     //     memStreamController.add([memUsed, memFreePercents]);
//     //   }
//     // });
//
//     xinputProc = await Process.start('xinput', ['test-xi2', '--root']);
//
//     xinputProc.outLines.forEach((element) {
//       if(element.contains('EVENT')) {
//         if(element.contains('Motion')) {
//           mouseStreamController.add('${DateTime.now()}: Mouse moving');
//         }
//         if(element.contains('ButtonPress')) {
//           mouseStreamController.add('${DateTime.now()}: Mouse click or scroll');
//         }
//         if(element.contains('KeyPress')) {
//           keyboardStreamController.add('${DateTime.now()}: Keyboard key pressed');
//         }
//         print('xinput: $element');
//       }
//     });
//   }
//
//   Future<void> initSystemTray() async {
//     await trayManager.setIcon(
//       Platform.isWindows ? 'images/tray_icon.ico' : 'assets/images/tray.png',
//     );
//
//     var items = Menu();
//     items.items = [
//       MenuItem(
//           key: 'show_window',
//           label: 'Show Window',
//           onClick: (value) async {
//             await windowManager.show(inactive: false);
//             await Process.run('wmctrl', ['-a', 'test_desktop']);
//             Process.run('wmctrl', ['-a', 'test_desktop']);
//           }),
//       MenuItem.separator(),
//       MenuItem(
//           key: 'exit_app',
//           label: 'Exit App',
//           onClick: (value) {
//             cpuProc.kill();
//             xinputProc.kill();
//             windowManager.destroy();
//           }),
//     ];
//     await trayManager.setContextMenu(items);
//   }
//
//   @override
//   void onWindowClose() async {
//     await windowManager.hide();
//   }
//
//   void _takeScreenshot() async {
//     setState(() {
//       _counter++;
//     });
//
//     if (Platform.isLinux) {
//       await Process.run('scrot', ['-F', '$_counter.jpg']);
//     } else if (Platform.isMacOS) {
//       await Process.run('screencapture', ['-x', '$_counter.jpg']);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             StreamBuilder(
//               stream: cpuStream,
//               builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                 if(snapshot.hasData) {
//                   return Text(snapshot.data);
//                 }
//                 return const SizedBox();
//               },
//             ),
//             StreamBuilder(
//               stream: memStream,
//               builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                 if(snapshot.hasData) {
//                   return Text('Memory used: ${snapshot.data[0]} (${snapshot
//                       .data[1]}% free)');
//                 }
//                 return const SizedBox();
//               },
//             ),
//             StreamBuilder(
//               stream: mouseStream,
//               builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                 if(snapshot.hasData) {
//                   return Text(snapshot.data);
//                 }
//                 return const SizedBox();
//               },
//             ),
//             StreamBuilder(
//               stream: keyboardStream,
//               builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                 if(snapshot.hasData) {
//                   return Text(snapshot.data);
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _takeScreenshot,
//         tooltip: 'Take Screenshot',
//         child: const Icon(Icons.photo_camera),
//       ),
//     );
//   }
// }