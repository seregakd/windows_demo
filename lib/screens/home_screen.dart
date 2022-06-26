import 'package:flutter/material.dart'hide MenuItem;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> with WindowListener, TrayListener{
  int _counter = 0;

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    _init();

    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                _addTray();
              },
              child: const Text('add tray')
            ),
            const SizedBox(height: 10,),
            TextButton(
                onPressed: () {
                  trayManager.destroy();
                },
                child: const Text('del tray')
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getScreenshot,
        tooltip: 'Get screenshot',
        child: const Icon(Icons.camera),
      ),
    );
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    _addTray();
  }

  void _getScreenshot() async {
    setState(() {
      _counter++;
    });

  }

  void _addTray() async{
    await trayManager.setIcon(
      Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'assets/images/tray_icon_original.png',
    );
    Menu trayMenu = Menu(
      items: [
        MenuItem(
            key: 'show_window',
            label: 'Show Window',
            onClick: (value) async {
              await windowManager.show();
            }),
        MenuItem.separator(),
        MenuItem(
            key: 'exit_app',
            label: 'Exit App',
            onClick: (value) {
              windowManager.destroy();
            }),
      ],
    );

    await trayManager.setContextMenu(trayMenu);
    await trayManager.setToolTip('demo_tray');
  }

  @override
  void onTrayIconMouseDown() async {
    await windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }
}