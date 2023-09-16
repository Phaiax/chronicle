import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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
      logger.e("Failed to initialize listener backend");
    }
  } else {
    logger.e("No listener backend for this platform");
  }

  getListenerBackend()!.addMouseListener((MouseEvent event) {
    if (MouseButtonEvent == event.runtimeType) {
      MouseButtonEvent mevent = event as MouseButtonEvent;
      if (mevent.type == MouseButtonEventType.leftButtonDown) {
        // doCapture(event.x.toInt(), event.y.toInt(),
        //     windowTitle: event.windowTitle);
      }
    }
  });

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  //Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  runApp(MyApp(settingsController: settingsController));

  await Window.setEffect(
    effect: WindowEffect.transparent,
    dark: true,
  );

  doWhenWindowReady(() {
    const initialSize = Size(1436, 764);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
