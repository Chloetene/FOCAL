// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.
import 'dart:async';
import 'package:cair_app_v3/widgets/new_note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './models/graphs.dart';
import './widgets/notes_list.dart';
import './widgets/new_note.dart';
import './models/dailynotes.dart';

import 'package:cair_app_v3/ble/bluetooth.dart';

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
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          )),
      home: MyStatelessWidget(),
    );
  }
}

final SnackBar snackBar = const SnackBar(content: Text('Showing Battery Percentage'));

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
class MyStatelessWidget extends StatefulWidget {
  MyStatelessWidget({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _MyStatelessWidgetState createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<MyStatelessWidget> {
  

  final String SERVICE_UUID = '0000180d-0000-1000-8000-00805f9b34fb';
  final String CHARACTERISTIC_UUID = '00002a6e-0000-1000-8000-00805f9b34fb';
  bool isReady;
  Stream<List<int>> stream;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
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
      id: 'g1',
      title: 'First Graph',
      amount: 10,
      date: DateTime.now(),
      data: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
    ),
    Graph(
      id: 'g2',
      title: 'Second Graph',
      amount: 8,
      date: DateTime.now(),
      data: [8.0, 4.0, 2.0, 1.0, 2.0, 4.0, 8.0],
    ),
  ];

  String titleInput;
  String firstanswer;
  String secondanswer;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: _onWillPop,
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        title: const Text(
          'FOCAL Homepage',
          style: TextStyle(fontFamily: 'Quicksand-Bold', color: Colors.purple),
        ),
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
            onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) => FlutterBlueApp())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: //!isReady
          // ? Center(
          //     child: Text(
          //       "Connect to an Espruino device.",
          //       style: TextStyle(fontSize: 24, color: Colors.red),
          //     ),
          //   )
          //: 
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

                    if (snapshot.connectionState == ConnectionState.active) {
                      // Get the data from received packet and convert to String
                      var currentValue1 = (snapshot.data)[0].toString();
                      var currentValue2 = (snapshot.data)[1].toString();

                      // Display data in the center of screen
                      return Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Card(
                            child: Container(
                                child: Container (
                                  width: double.infinity,
                                  child: Text('${currentValue1}, ${currentValue2}',
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
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _startAddNewNote(context),
        ),
      )
    );
  }
}

