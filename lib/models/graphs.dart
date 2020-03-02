import 'package:flutter/material.dart';

class Graph {
  String id;
  String title;
  double amount;
  DateTime date;
  List<double> data;

  Graph({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
    @required this.data,
  });
}
