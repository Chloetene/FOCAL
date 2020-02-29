import 'package:flutter/material.dart';

class Graph {
  String id;
  String title;
  double amount;
  DateTime date;

  Graph({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });
}
