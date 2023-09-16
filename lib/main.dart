import 'package:chronicle/src/database/db.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  if (getListenerBackend() != null) {
    HidListenerBackend listener = getListenerBackend()!;
    if (!listener.initialize()) {
      print("Failed to initialize listener backend");
    } else {
      print("initialized hid listener");
    }
  } else {
    print("No listener backend for this platform");
  }

  getListenerBackend()!.addKeyboardListener((event) {
    print("${event.logicalKey.debugName}");
  });

  getListenerBackend()!.addKeyboardListener((p0) {
    print("${p0.physicalKey.debugName}");
  });
  getListenerBackend()!.addMouseListener((MouseEvent event) {
    if (MouseButtonEvent == event.runtimeType) {
      //MouseButtonEvent mbtn = (MouseButtonEvent)event;
    }
  });

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
