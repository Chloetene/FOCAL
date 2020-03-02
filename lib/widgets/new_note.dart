import 'package:flutter/material.dart';

class NewNote extends StatefulWidget {
  final Function addNt;

  NewNote(this.addNt);

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  final ansoneController = TextEditingController();

  final anstwoController = TextEditingController();

  final ansthreeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  labelText: 'How are you feeling overall?'),
              controller: ansoneController,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'How are you doing with work?'),
              controller: anstwoController,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Put any extra notes here.'),
              controller: ansthreeController,
            ), //TextField(decoration: InputDecoration(labelText: 'How are you feeling today?'),),
            FlatButton(
              child: Text('Save'),
              color: Colors.lightBlue[50],
              textColor: Colors.lightBlue[500],
              onPressed: () {
                widget.addNt(ansoneController.text, anstwoController.text, ansthreeController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}