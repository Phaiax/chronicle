import 'dart:io';
import 'dart:math';

import 'package:chronicle/main.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:chronicle/src/database/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

import 'package:chronicle/src/timeline_view/timeline_view.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:path_provider/path_provider.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  RunSomeStuffAfterInitState createState() {
    return RunSomeStuffAfterInitState();
  }
}

class RunSomeStuffAfterInitState extends State<MyApp> {
  RunSomeStuffAfterInitState();

  @override
  void initState() {
    super.initState();

    // Adding a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to run after the app is fully loaded
      onAppFullyLoaded();
    });
  }

  void onAppFullyLoaded() {
    // This is the code that gets executed after the app is fully loaded
    logger.i("The app has been fully loaded!");
    //  MouseEventPlugin.startListening(onMouseEvent);
    DatabaseHelper().debugPrintDatabaseScreenshots(); // Trigger initializatoin
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case TimelinePage.routeName:
                    return const TimelinePage(
                        title: 'Your Title', key: Key('Your Key'));
                  case SampleItemListView.routeName:
                  default:
                    return const TimelinePage(
                        title: 'Wowi', key: Key('Your Key'));
                }
              },
            );
          },
        );
      },
    );
  }
}

void doCapture(int x, int y, {String? windowTitle}) async {
  Directory directory = await getApplicationDocumentsDirectory();
  String imageName = 'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
  String imagePath =
      p.join(directory.path, 'chronicle', 'Screenshots', imageName);

  CapturedData? capturedData = await screenCapturer.capture(
    mode: CaptureMode.screen, // screen, window
    imagePath: imagePath,
    copyToClipboard: false,
    silent: true,
  );
  String snippetPath = "";
  if (capturedData != null && capturedData.imageBytes != null) {
    img.Image? imgFull = img.decodePng(capturedData.imageBytes!);
    snippetPath = imagePath.replaceAll(".png", ".small.png");
    if (imgFull != null) {
      int width = min(imgFull.width, 300);
      int height = min(imgFull.height, 50);
      int snippetX = max(0, x - (width / 2).floor());
      int snippetY = max(0, y - (height / 2).floor());
      img.Image snippet = img.copyCrop(imgFull,
          x: snippetX, y: snippetY, width: width, height: height);
      img.encodePngFile(snippetPath, snippet);
    }

    DatabaseHelper().insertScreenshot(
        mousex: x,
        mousey: y,
        screenshotFullPath: imagePath,
        screenshotSnippetPath: snippetPath,
        activewindow: windowTitle);
    logger.i("Captured at $x $y ($windowTitle)!");
  }
  // capturedData.
}
