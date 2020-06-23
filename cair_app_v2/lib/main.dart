// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:cair_app_v2/widgets/new_note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import './models/graphs.dart';
import './widgets/notes_list.dart';
import './widgets/new_note.dart';
import './models/dailynotes.dart';

import 'package:cair_app_v2/ble/bluetooth.dart';
import 'package:cair_app_v2/ble/sensor_page.dart';
import './widgets/graphwidget.dart';
import './util/dataliststream.dart';

import 'dart:async';
import 'dart:math';

Stream<List<int>> count_list() async* {
  var rng = new Random();
  while (true) {
    await new Future.delayed(new Duration(milliseconds: 1500));
    yield [rng.nextInt(20), rng.nextInt(20), rng.nextInt(20), rng.nextInt(20)];
  }
}

void main() => runApp(MyApp());

/// Settings for initializing the plugin for each platform
class InitializationSettings {
  /// Settings for Android
  final AndroidInitializationSettings android;

  /// Settings for iOS
  final IOSInitializationSettings ios;

  const InitializationSettings(this.android, this.ios);
}

/// Contains notification settings for each platform
class NotificationDetails {
  /// Notification details for Android
  final AndroidNotificationDetails android;

  /// Notification details for iOS
  final IOSNotificationDetails iOS;

  const NotificationDetails(this.android, this.iOS);
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          )),
      home: CairApp(),
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final SnackBar snackBar =
    const SnackBar(content: Text('Showing Battery Percentage'));

void openPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text(
            'This is the settings page',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    },
  ));
}

void openNotesPage(BuildContext context, _userNotes) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes', style: TextStyle(color: Colors.brown)),
          backgroundColor: Colors.brown[100],
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NotesList(_userNotes),
                //NotesList(x),
              ]),
        ),
      );
    },
  ));
}

/// This is the stateless widget that the main application instantiates.
class CairApp extends StatefulWidget {
  CairApp({Key key}) : super(key: key);

  @override
  _CairAppState createState() => _CairAppState();
}

class _CairAppState extends State<CairApp> {
  bool init = true;
  bool bt_init = true;

  //DataListStream dlstream = new DataListStream(width: 86400);
  BluetoothConnection connection;
  FlutterBlueApp btapp;

  final List<Notes> _userNotes = [
    /*Notes(
      ansone: 'I am good',
      anstwo: 'I am fine',
      ansthree: 'I am great',
      date: DateTime.now(),
    ),*/
  ];

  void _addNewNote(String ntone, String nttwo, String ntthree) {
    final newNt = Notes(
      ansone: ntone,
      anstwo: nttwo,
      ansthree: ntthree,
      date: DateTime.now(),
    );

    setState(() {
      _userNotes.add(newNt);
    });
    Navigator.of(context).pop(); //close + button after entering note
  }

  void _startAddNewNote(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewNote(_addNewNote),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  final List<Graph> graphs = [
    Graph(
      title: 'Heart Rate (bpm)',
      date: DateTime.now(),
      column: 0,
    ),
    Graph(
      title: 'SpO2 (%)',
      date: DateTime.now(),
      column: 1,
    ),
    Graph(
      title: 'Temperature (°F)',
      date: DateTime.now(),
      column: 2,
    ),
    Graph(
      title: 'Pressure (N)',
      date: DateTime.now(),
      column: 3,
    ),
  ];

  final dataSets = [
    [
      new Pair(0, 71),
      new Pair(10, 62),
      new Pair(20, 65),
      new Pair(30, 72),
      new Pair(40, 63),
      new Pair(50, 65),
      new Pair(60, 67),
      new Pair(70, 65),
    ],
    [
      new Pair(0, 98),
      new Pair(10, 93),
      new Pair(20, 97),
      new Pair(30, 90),
      new Pair(40, 97),
      new Pair(50, 98),
      new Pair(60, 94),
      new Pair(70, 90),
    ],
    [
      new Pair(0, 82),
      new Pair(10, 82),
      new Pair(20, 78),
      new Pair(30, 84),
      new Pair(40, 83),
      new Pair(50, 84),
      new Pair(60, 83),
      new Pair(70, 81),
    ],
    [
      new Pair(0, 12),
      new Pair(10, 18),
      new Pair(20, 11),
      new Pair(30, 9),
      new Pair(40, 11),
      new Pair(50, 6),
      new Pair(60, 14),
      new Pair(70, 9),
    ],
  ];

  String titleInput;
  String firstanswer;
  String secondanswer;

  void _init() {
    //dlstream.set_stream(count_list());
    //dlstream.run();
  }

  @override
  Widget build(BuildContext context) {

    if (init) {
      _init();
      init = false;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        title: const Text(
          'FOCAL Homepage',
          style: TextStyle(
            fontFamily: 'Quicksand-Bold',
            color: Colors.deepPurple,
          ),
        ),
        //textTheme: Color(aaaa)
        //backgroundColor: Colors.lightBlue[100],
        leading: IconButton(
          icon: const Icon(Icons.note),
          tooltip: 'Show notes',
          color: Theme.of(context).primaryColorDark,
          onPressed: () {
            openNotesPage(context, _userNotes);
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.battery_full),
            tooltip: 'Show Snackbar',
            color: Colors.green,
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).primaryColorDark,
            tooltip: 'Settings',
            onPressed: () {
              if (bt_init) {
                btapp = new FlutterBlueApp(connection: connection);
                bt_init = false;
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => btapp));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Theme.of(context).primaryColorDark,
              child: Container(
                width: double.infinity,
                child: Text('Overall Stress Level:'),
              ),
              margin: EdgeInsets.all(5),
              elevation: 5,
            ),
            //UserNotes(),
            Column(
              children: graphs.map((gr) {
                return Container(
                  width: 400,
                  child: Card(
                    child: GraphWidget( //need to import graphwidget
                      name: gr.title,
                      width: 300,
                      height: 150,
                      color: Theme.of(context).primaryColorDark,
                      //stream: dlstream,
                      column: gr.column,
                      use_static_data: false,
                      staticData: dataSets[gr.column],
                    ),
                  ),
                );
              }).toList(),
            ),
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewNote(context),
      ),
    );
  }
}
