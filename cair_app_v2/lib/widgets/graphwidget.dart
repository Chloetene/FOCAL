import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import './../util/dataliststream.dart';

/// GraphWidget class definition
class GraphWidget extends StatefulWidget {
  GraphWidget({Key key, this.name, this.width, this.height, this.color, this.stream, this.column, this.use_static_data, this.staticData}) : super(key: key);

  final String name;
  final double width;
  final double height;
  final Color color;
  final int column;
  final DataListStream stream;
  final bool use_static_data;
  final List<Pair> staticData;

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

/// Sample linear data type.
class Pair {
  final int x;
  final int y;
  Pair(this.x, this.y);
}

/// GraphWidgetState class definition
class _GraphWidgetState extends State<GraphWidget> {
  bool _init = true;
  List<double> _data = [];
  List<DateTime> _time = [];
  DataListStream _dstream;
  
  void _update() {
    setState(
      () {
        _data = _dstream.getData(widget.column);
        _time = _dstream.getTimes();
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

    //create pair data
    List<Pair> data_pairs = [];
    if (widget.use_static_data) {
      data_pairs = widget.staticData;
    } else {
      for (var i = 0; i < _data.length; i++) {
        data_pairs.add(
          new Pair(
            (_time[i].hour * 10 * 10 * 10 * 10) + (_time[i].minute * 10 * 10) + _time[i].second,
            _data[i].toInt()
          )
        );
        //print("${widget.column}: (${data_pairs.last.x}, ${data_pairs.last.y})\n");
      }
    }

    final series_list = [
      charts.Series<Pair, int>(
        id: 'Data',
        colorFn: (Pair pair, _) {
          return charts.ColorUtil.fromDartColor(
            Color(0xFF0096FF)
          );
        },
        areaColorFn: (Pair pair, _) {
          //return charts.MaterialPalette.blue.shadeDefault.lighter;
          return charts.ColorUtil.fromDartColor(
            Color(0xCC96C8FF)
          );
        },
        domainFn: (Pair pair, _) => pair.x,
        measureFn: (Pair pair, _) => pair.y,
        data: data_pairs,
      ),
    ];

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
        
        Container(
          width: widget.width,
          height: widget.height,
          
          child: charts.LineChart(
            series_list,

            defaultRenderer: new charts.LineRendererConfig(
              includeArea: true,
              stacked: true,
            ),
            
            domainAxis: new charts.NumericAxisSpec(
              //labelStyle: new charts.TextStyleSpec(
              //  fontSize: 8,
              //  color: charts.MaterialPalette.black,
              //),
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              renderSpec: new charts.GridlineRendererSpec(
                labelStyle: new charts.TextStyleSpec(
                  fontSize: 12,
                  color: charts.MaterialPalette.black,
                ),
                lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.black,
                ),
                labelAnchor: charts.TickLabelAnchor.after,
                labelJustification: charts.TickLabelJustification.outside,
              ),
            ),
          ),

        ),

        Text(
          "Time (s)",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
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