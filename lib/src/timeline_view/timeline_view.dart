import 'dart:io';

import 'package:chronicle/src/timeline_view/fullscreen_view.dart';
import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import '../database/db.dart';
import '../settings/settings_view.dart';
import 'data.dart';

class TimelinePage extends StatefulWidget {
  static const routeName = '/timeline'; // add this line
  TimelinePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final PageController pageController =
      PageController(initialPage: 1, keepPage: true);
  int pageIx = 1;

  final Future<List<Doodle>> _doodlesFuture = fetchData();
  List<Doodle>? _doodles; // Only valid during build()

  static Future<List<Doodle>> fetchData() async {
    List<Doodle> doodles = [];
    for (Map<String, dynamic> screenshot
        in await DatabaseHelper().getAllScreenshots()) {
      doodles.add(Doodle(
          name: screenshot["activewindow"] ?? "",
          time: (screenshot["time"] ?? 0).toString(),
          content: screenshot["activewindow"] ?? "",
          doodle: (screenshot["screenshotSnippetPath"] as String? ?? ""),
          icon: Icon(Icons.star, color: Colors.white),
          iconBackground: Colors.cyan));
    }
    return doodles;
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically select content for main area:
    FutureBuilder<List<Doodle>> pageView = FutureBuilder<List<Doodle>>(
      future: _doodlesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Doodle>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Spinner as long as the timeline data is loading
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Text on error (don't know what should trigger this)
          print(snapshot.error);
          return Text('Error: ${snapshot.error}');
        } else {
          // The PageView once the doodle list is available
          List<Widget> pages = [
            timelineModel(TimelinePosition.Left, snapshot.data!),
            timelineModel(TimelinePosition.Center, snapshot.data!),
            timelineModel(TimelinePosition.Right, snapshot.data!)
          ];
          return PageView(
            onPageChanged: (i) => setState(() => pageIx = i),
            controller: pageController,
            children: pages,
          );
        }
      },
    );

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIx,
            onTap: (i) => pageController.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_left),
                label: "LEFTY",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_center),
                label: "CENTER",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_right),
                label: "RIGHTY",
              ),
            ]),
        appBar: AppBar(
          title: const Text('Chronicle'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
        body: pageView);
  }

  timelineModel(TimelinePosition position, List<Doodle> doodles) {
    _doodles = doodles;
    return Timeline.builder(
        itemBuilder: centerTimelineBuilder,
        itemCount: doodles.length,
        physics: position == TimelinePosition.Left
            ? ClampingScrollPhysics()
            : BouncingScrollPhysics(),
        position: position);
  }

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    final doodle = _doodles![i];
    final textTheme = Theme.of(context).textTheme;
    var isRight = i % 2 == 1;
    if (pageIx == 0) {
      isRight = true;
    }
    if (pageIx == 2) {
      isRight = false;
    }
    return TimelineModel(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenView(
                  imageUrl: doodle.doodle,
                  heroTag: 'heroTag$i'.toString(),
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isRight
                  ? Row(
                      children: <Widget>[
                        Text(doodle.time, style: textTheme.caption),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                doodle.name,
                                style: textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Hero(
                                  tag: 'heroTag$i',
                                  child: Image.file(
                                    File(doodle.doodle),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                doodle.name,
                                style: textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Hero(
                                  tag: 'heroTag$i',
                                  child: Image.file(
                                    File(doodle.doodle),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(doodle.time, style: textTheme.caption),
                      ],
                    ),
            ),
          ),
        ),
        position:
            isRight ? TimelineItemPosition.right : TimelineItemPosition.left,
        isFirst: i == 0,
        isLast: i == _doodles!.length,
        iconBackground: doodle.iconBackground,
        icon: doodle.icon);
  }
}
