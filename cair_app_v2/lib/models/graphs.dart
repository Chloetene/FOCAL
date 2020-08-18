import 'package:flutter/material.dart';
import './../util/dataliststream.dart';

class Graph {
  String title;
  DateTime date;
  int column;

  Graph({
    @required this.title,
    @required this.date,
    @required this.column,
  });
}
