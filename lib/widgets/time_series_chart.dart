import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TempSeries {
  final DateTime time;
  final int temp;

  TempSeries(this.time, this.temp);
}

class TemperatureChart extends StatelessWidget {
  final List<TempSeries> data;

  TemperatureChart({@required this.data});

  @override 
  Widget build(BuildContext context) {

    List<charts.Series<TempSeries, DateTime>> series
    = [
      charts.Series(
        id: "Temperature",
        data: data,
        domainFn: (TempSeries temp, _) => temp.time,
        measureFn: (TempSeries temp, _) => temp.temp,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      )
    ];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Temperature (°C)",
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Expanded(
                child: charts.TimeSeriesChart(series, animate: true),
              )
            ],
          )
        ),
        
      ),
    );
  }
}