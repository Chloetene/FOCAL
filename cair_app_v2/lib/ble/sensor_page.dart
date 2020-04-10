import 'dart:async';
import 'dart:math';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oscilloscope/oscilloscope.dart';
import './../util/dataliststream.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final String SERVICEUUID = '0000180d-0000-1000-8000-00805f9b34fb';
  final String CHARACTERISTICUUID = '00002a6e-0000-1000-8000-00805f9b34fb';
  bool isReady;
  Stream<List<int>> stream;
  List<double> traceDust = List();

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  /* 
    Connect to the selected device with a 15 second timer before timeout
  */
  connectToDevice({bool assignstream = false, DataListStream dlstream}) async {
    if (widget.device == null) {
      Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        Pop();
      }
    });

    await widget.device.connect();
    discoverServices(assignstream: assignstream, dlstream: dlstream);
  }

  /* 
    Disconnect from the device
  */
  disconnectFromDevice() {
    if (widget.device == null) {
      Pop();
      return;
    }

    widget.device.disconnect();
  }

  /* 
    Asynchrously check for device service and characteristic UUIDs 
  */
  discoverServices({bool assignstream = false, DataListStream dlstream}) async {
    if (widget.device == null) {
      Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    // Iterate through each found service UUIDs of the device
    services.forEach((service) {
      // Check if the wanted service UUID is available
      if (service.uuid.toString() == SERVICEUUID) {
        // Iterate through each found characteristic UUIDs of the device
        service.characteristics.forEach((characteristic) {
          // Check if the wanted characteristic UUID is available
          if (characteristic.uuid.toString() == CHARACTERISTICUUID) {
            // Sets the notify parameter of the bluetooth device to FALSE to indicate
            // most recent sent data was received successfully
            characteristic.setNotifyValue(!characteristic.isNotifying);
            // Read the value inside the characteristic UUID
            stream = characteristic.value;

            if (assignstream)
              dlstream.set_stream(characteristic.value);

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      Pop();
    }
  }

  /* 
    Display a notification that reasses the user for device disconnection
  */
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

  /* 
    Display a notification of current situation in the nav bar
  */
  Pop() {
    Navigator.of(context).pop(true);
  }
  
  /* 
    Decodes received data using UTF8 configuration. 
    NOTE: Not used in ble_test
  */
  String dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  /* 
    Widget building 
  */
  @override
  Widget build(BuildContext context) {
    // Oscilloscope settings
    Oscilloscope oscilloscope = Oscilloscope(
      showYAxis: true,
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.white,
      yAxisMax: 200.0,
      yAxisMin: 40.0,
      dataSet: traceDust,
    );

    // Sensor page display settings
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sensor'),
        ),
        body: Container(
            // Wait until device is connected and data was received successfully
            child: !isReady
                ? Center(
                    child: Text(
                      "Waiting...",
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    ),
                  )
                : Container(
                    child: StreamBuilder<List<int>>(
                      stream: stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<int>> snapshot) {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');

                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          // Get the data from received packet and convert to String
                          var currentValue1 = (snapshot.data)[0].toString();
                          var currentValue2 = (snapshot.data)[1].toString();
                          // Add data to oscilloscope datapoints
                          traceDust.add(double.tryParse(currentValue1) ?? 0);

                          // Display data in the center of screen
                          return Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Current value from Espruino',
                                          style: TextStyle(fontSize: 14)),
                                      Text('${currentValue1}, ${currentValue2}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24))
                                    ]),
                              ),
                              Expanded(
                                flex: 1,
                                child: oscilloscope,
                              )
                            ],
                          ));
                        } else {
                          return Text('Check the stream');
                        }
                      },
                    ),
                  )),
      ),
    );
  }
}