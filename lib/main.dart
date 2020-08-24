// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'dart:async';
//import 'package:cair_app_v3/widgets/new_note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

//import './models/graphs.dart';
import './widgets/notes_list.dart';
import './widgets/new_note.dart';
import './widgets/overall.dart';
import './models/dailynotes.dart';

import 'package:cair_app_v3/ble/bluetooth.dart';
//import 'package:cair_app_v3/ble/sensor_page.dart';
//import './widgets/graphwidget.dart';
//import './util/dataliststream.dart';

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

void openNotesPage(BuildContext context, _userNotes, _deleteNote) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes', style: TextStyle(color: Colors.purple)),
          backgroundColor: Colors.purple[100],
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NotesList(_userNotes, _deleteNote),
                //NotesList(x),
              ]),
        ),
      );
    },
  ));
}

//SnackBar show_snackbar(context) {
//  return scaffoldKey.currentState.showSnackBar(snackBar);
//}


/// This is the stateless widget that the main application instantiates.
class CairApp extends StatefulWidget {
  CairApp({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _CairAppState createState() => _CairAppState();
}

class _CairAppState extends State<CairApp> {
  final String SERVICE_UUID = '0000180d-0000-1000-8000-00805f9b34fb';
  final String CHARACTERISTIC_UUID = '00002a6e-0000-1000-8000-00805f9b34fb';
  bool isReady;
  Stream<List<int>> stream;
  final List<Notes> _userNotes = [];

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  void _addNewNote(String ntone, String nttwo, String ntthree) {
    final newNt = Notes(
      id: DateTime.now().toString(),
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

  void _deleteNote(String id) {
    setState(() {
      _userNotes.removeWhere((nt) => nt.id == id);
    });
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

  /* 
    Connect to the selected device with a 15 second timer before timeout
  */
  connectToDevice() async {
    if (widget.device == null) {
      //_Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        //_Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    // Iterate through each found service UUIDs of the device
    services.forEach((service) {
      // Check if the wanted service UUID is available
      if (service.uuid.toString() == SERVICE_UUID) {
        // Iterate through each found characteristic UUIDs of the device
        service.characteristics.forEach((characteristic) {
          // Check if the wanted characteristic UUID is available
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            // Sets the notify parameter of the bluetooth device to FALSE to indicate
            // most recent sent data was received successfully
            characteristic.setNotifyValue(!characteristic.isNotifying);
            // Read the value inside the characteristic UUID
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _Pop();
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No')),
                new FlatButton(
                    onPressed: () {
                      disconnectFromDevice();
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes')),
              ],
            ) ??
            false);
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    /*if (init) {
      _init();
      init = false;
    }*/
    final appBar = AppBar(
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
          //openNotesPage(context, _userNotes);
          openNotesPage(context, _userNotes, _deleteNote);
        },
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.battery_full),
          tooltip: 'Show Snackbar',
          color: Colors.green,
          onPressed: () => scaffoldKey.currentState.showSnackBar(snackBar),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          alignment: Alignment.centerLeft,
          color: Theme.of(context).primaryColorDark,
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => FlutterBlueApp())),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      //key: scaffoldKey,
      child: Scaffold(
        key: scaffoldKey,
        appBar: appBar,
        body: SingleChildScrollView(
          child: !isReady
              ? Center(
                  child: Text(
                    "Connect to an Espruino device.",
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        height: (MediaQuery.of(context).size.height -
                                appBar.preferredSize.height -
                                MediaQuery.of(context).padding.top) *
                            0.2,
                        child: Overall()),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Card(
                            color: Theme.of(context).primaryColorDark,
                            child: Container(
                              width: double.infinity,
                              child: Text('CHART NO. 1'),
                            ),
                            margin: EdgeInsets.all(5),
                            elevation: 5,
                          ),
                          Container(
                            child: StreamBuilder<List<int>>(
                              stream: stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<int>> snapshot) {
                                if (snapshot.hasError)
                                  return Text('Error: ${snapshot.error}');

                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  // Get the data from received packet and convert to String
                                  var currentValue1 =
                                      (snapshot.data)[0].toString();
                                  var currentValue2 =
                                      (snapshot.data)[1].toString();

                                  // Display data in the center of screen
                                  return Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Card(
                                        child: Container(
                                          child: Container(
                                            width: double.infinity,
                                            child: Text(
                                                '${currentValue1}, ${currentValue2}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ));
                                } else {
                                  return Text('Check the stream');
                                }
                              },
                            ),
                          )
                        ]),
                  ],
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _startAddNewNote(context),
        ),
      ),
    );
  }
}
