import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert' show utf8;

class SensorPage extends StatefulWidget {

  const SensorPage({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override 
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  
  final String SERVICE_UUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  final String CHARACTERISTIC_UUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  bool isReady;
  Stream<List<int>> stream;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  /* 
    Connect to a selected device 
  */
  connectToDevice() async {
    if(widget.device == null){
      _Pop();
      return;
    }

    // Set timer for device connection attempt
    new Timer(const Duration(seconds: 60), (){
      if(!isReady){
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  /* 
    Disconnect connected/attempted for connection device
  */
  disconnectFromDevice(){
    if(widget.device == null) {
      _Pop();
      return;
    }
    
    widget.device.disconnect();
  }

  /* 
    Search for nearby available bluetooth device services to connect with
  */
  discoverServices() async {
    if(widget.device == null) {
      _Pop();
      return;
    }

    // Create a list of discovered bluetooth device services
    List<BluetoothService> services = await widget.device.discoverServices();
    
    // Compare each item in list if it has the same SERVICE and CHARACTERISTIC UUID.
    // Extract the value inside the characteristic uuid if true.
    services.forEach((service){
      if(service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic){
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (isReady) {
      _Pop();
    }
  }

  Future<bool> _onWillPop(){
    return showDialog(context: context, builder: (context)=> new AlertDialog(title: Text('Are you sure?'), content: Text('Do you want to disconnect device and go back?'), actions: <Widget>[
      new FlatButton(onPressed: ()=> Navigator.of(context).pop(false), child: new Text('No')),
      new FlatButton(onPressed: (){
        disconnectFromDevice();
        Navigator.of(context).pop(true);
      }, child: new Text('Yes')),
    ],
    ) ??
    false);
  }

  /* 
    Show notification of device status
  */
  _Pop(){
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  // Interface building
  @override 
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Temperature Sensor'),
        ),
        body: Container(child: !isReady 
        ? Center(
          child: Text(
          "Waiting...", style: TextStyle(fontSize: 24, color: Colors.red),
          ),
          )
        : Container(
          child: StreamBuilder<List<int>>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if(snapshot.hasError) return Text('Error: ${snapshot.error}');

            if(snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data);

              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Current value from Sensor', 
                  style: TextStyle(fontSize: 14)),
                  Text('${currentValue} Celsius', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24))]));
                
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