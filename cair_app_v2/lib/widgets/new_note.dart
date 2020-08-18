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

  void submitData() {
    final enteredTen = ansoneController.text;
    final enteredReason = anstwoController.text;
    final enteredChange = ansthreeController.text;

    if (enteredTen.isEmpty || enteredReason.isEmpty || enteredChange.isEmpty) {
      return;
    }

    widget.addNt(ansoneController.text, anstwoController.text, ansthreeController.text);
  
  }

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
                  labelText: 'How do you feel on a scale of 1 to 10? 10 being best.'),
              controller: ansoneController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => submitData,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Why did you choose that number?'),
              controller: anstwoController,
              onSubmitted: (_) => submitData(),
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'What steps will you take to improve this number?'),
              controller: ansthreeController,
              onSubmitted: (_) => submitData(),
            ), //TextField(decoration: InputDecoration(labelText: 'How are you feeling today?'),),
            FlatButton(
              child: Text('Save'),
              color: Colors.lightBlue[50],
              textColor: Colors.lightBlue[500],
              onPressed: submitData,
            ),
          ],
        ),
      ),
    );
  }
}