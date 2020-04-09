import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

/// Wrapper for stream pushing into list (not generic)
class DataListStream {
  Stream<List<int>> _stream;
  List<List<int>> _data = [];
  int _width = 1;
  int _c = 0;
  bool _run = false;
  bool _set = false;

  DataListStream({int width, Stream<List<int>> stream}) {
    if (width != null)
      _width = width;
    if (stream != null)
      setstream(stream);
  }

  void setstream(Stream<List<int>> stream) {
    _set = true;
    _stream = stream;
  }
  
  void unsetstream() {
    _stream = Stream<List<int>>.empty();
    _set = false;
  }

  void run() async {
    if (!_set)
      return;
    _run = true;

    await for (var a in _stream) {
      if (!_run)
        break;
      _c++;
      _data.add(a);

      if (_data.length > _width)
        _data.removeAt(0);
    }
  }

  void stop() {
    _run = false;
  }

  List<double> getData(int column) {
    List<double> columndata = [];

    for (var a in _data)
      if (a.length > 0)
        columndata.add(a[column].toDouble());
    
    return columndata;
  }

  Stream<List<int>> getStream() => _stream;
  int getC() => _c;
  int getWidth() => _width;
  bool isSet() => _set;
  bool isRunning() => _run;
}

///GraphWidget class definition
class GraphWidget extends StatefulWidget {
  GraphWidget({Key key, this.name, this.width, this.height, this.color, this.stream, this.sampleNum}) : super(key: key);

  final String name;
  final double width;
  final double height;
  final Color color;
  final int sampleNum;
  final Stream<List<int>> stream;

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

///GraphWidgetState class definition
class _GraphWidgetState extends State<GraphWidget> {
  bool _init = true;
  List<double> _data = [];
  DataListStream _dstream;

  void _update() {
    setState(
      () {
        _data = _dstream.getData(0);
      }
    );
  }

  void _initfunc() {
    _dstream = new DataListStream(width: widget.sampleNum);
    _dstream.setstream(widget.stream);
    _dstream.run();
  }

  @override
  Widget build(BuildContext context) {
    if (_init) {
      _initfunc();
      _init = false;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),

        //Spacer(),

        Container(
          width: widget.width,
          height: widget.height,

          decoration: BoxDecoration(
            border: Border.all(
              color: widget.color,
              width: 3.0,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),

          child: Sparkline(
            data: _data,
            lineGradient: new LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red, Colors.yellow, Colors.green],
            ),
          ),

        ),

        FlatButton(
          onPressed: _update,
          textColor: Colors.cyan,
          splashColor: Colors.cyan[100],
          disabledColor: Colors.grey,
          child: Text(
            "Update",
          ),
        ),
      ],
    );
  }
}
/*
/// DEMO ====================================================================================================================================================================

Stream<List<int>> count_list() async* {
  var rng = new Random();
  while (true) {
    await new Future.delayed(new Duration(milliseconds: 500));
    yield [rng.nextInt(20), rng.nextInt(20)];
  }
}

void main() => runApp(BaseApp());

class BaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Test'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            GraphWidget(
              name: "Test Graph",
              width: 300.0,
              height: 100.0,
              stream: count_list(),
              sampleNum: 10,
            ),

          ],
        ),
      ),
    );
  }
}*/