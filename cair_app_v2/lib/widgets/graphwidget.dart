import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import './../util/dataliststream.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

///GraphWidget class definition
class GraphWidget extends StatefulWidget {
  GraphWidget({Key key, this.name, this.width, this.height, this.color, this.stream, this.column}) : super(key: key);

  final String name;
  final double width;
  final double height;
  final Color color;
  final DataListStream stream;
  final int column;

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
        _data = _dstream.getData(widget.column);
      }
    );
  }

  void _initfunc() {
    _dstream = widget.stream;
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