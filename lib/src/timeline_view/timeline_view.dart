import 'package:chronicle/src/timeline_view/fullscreen_view.dart';
import 'package:flutter/material.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
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

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      timelineModel(TimelinePosition.Left),
      timelineModel(TimelinePosition.Center),
      timelineModel(TimelinePosition.Right)
    ];

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIx,
            onTap: (i) => pageController.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_left),
                label: "LEFT",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_center),
                label: "CENTER",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_align_right),
                label: "RIGHT",
              ),
            ]),
        appBar: AppBar(
          title: const Text('Sample Items'),
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
        body: PageView(
          onPageChanged: (i) => setState(() => pageIx = i),
          controller: pageController,
          children: pages,
        ));
  }

  timelineModel(TimelinePosition position) => Timeline.builder(
      itemBuilder: centerTimelineBuilder,
      itemCount: doodles.length,
      physics: position == TimelinePosition.Left
          ? ClampingScrollPhysics()
          : BouncingScrollPhysics(),
      position: position);

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    final doodle = doodles[i];
    final textTheme = Theme.of(context).textTheme;
    return TimelineModel(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenView(imageUrl: doodle.doodle),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                    tag: 'imageHero',
                    child: Image.network(doodle.doodle),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(doodle.time, style: textTheme.caption),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    doodle.name,
                    style: textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        position:
            i % 2 == 0 ? TimelineItemPosition.right : TimelineItemPosition.left,
        isFirst: i == 0,
        isLast: i == doodles.length,
        iconBackground: doodle.iconBackground,
        icon: doodle.icon);
  }
}