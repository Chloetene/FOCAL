import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dailynotes.dart';
//import './user_notes.dart';

class NotesList extends StatelessWidget {
  final List<Notes> notes;

  NotesList(this.notes);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: notes.map((gr) {
            return Card(
              color: Colors.brown[50],
              child: Column(
                children: <Widget>[
                  Container(
                    //color: Colors.brown[50],
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.brown[300],
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Notes for ' +
                          DateFormat.yMd().add_jm().format(
                              gr.date), //can do .format('yyyy-MM-dd'), etc.,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown[300],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.brown[300],
                        width: 3,
                      ),
                    ),
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Overall: ' + gr.ansone,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.brown[300],
                          ),
                        ),
                        Text(
                          'Work: ' + gr.anstwo,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 15,

                            color: Colors.brown[300],
                          ),
                        ),
                        Text(
                          'Notes: ' + gr.ansthree,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.brown[300],
                          ),
                        ),
                        /*
                        Text(
                          'Last Update: ' +
                              DateFormat.yMd().add_jm().format(gr
                                  .date), //can do .format('yyyy-MM-dd'), etc.
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        ), */
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
