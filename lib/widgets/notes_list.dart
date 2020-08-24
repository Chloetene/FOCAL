import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../models/dailynotes.dart';
//import './user_notes.dart';

class NotesList extends StatelessWidget {
  final List<Notes> notes;
  final Function deleteNote;
  //NotesList(this.notes);
  NotesList(this.notes, this.deleteNote);

  @override
  Widget build(BuildContext context) {
    Color _MyColor(index) {
      //const _MyColor(this.color, this.name);

      Color variableColor;

      if (notes[index].ansone == "10") {
        variableColor = Colors.green;
        return variableColor;
      } else if (notes[index].ansone == "9") {
        variableColor = Colors.lime[700];
        return variableColor;
      } else if (notes[index].ansone == "8") {
        variableColor = Colors.lime;
        return variableColor;
      } else if (notes[index].ansone == "7") {
        variableColor = Colors.yellow;
        return variableColor;
      } else if (notes[index].ansone == "6") {
        variableColor = Colors.yellow[600];
        return variableColor;
      } else if (notes[index].ansone == "5") {
        variableColor = Colors.yellow[800];
        return variableColor;
      } else if (notes[index].ansone == "4") {
        variableColor = Colors.orange;
        return variableColor;
      } else if (notes[index].ansone == "3") {
        variableColor = Colors.orange[700];
        return variableColor;
      } else if (notes[index].ansone == "2") {
        variableColor = Colors.deepOrange;
        return variableColor;
      } else if (notes[index].ansone == "1") {
        variableColor = Colors.deepOrange[900];
        return variableColor;
      } else {
        Color variableColor = Colors.black;
        return variableColor;
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: notes.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No notes added yet!',
                  style: Theme.of(context).textTheme.title,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _MyColor(index),
                      radius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: FittedBox(child: Text(notes[index].ansone)),
                      ),
                    ),
                    title: Text(
                      notes[index].anstwo + '\n' + notes[index].ansthree,
                      style: Theme.of(context).textTheme.title,
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().format(notes[index].date),
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Theme.of(context).errorColor,
                      //onPressed: () {},
                      onPressed: () => deleteNote(notes[index].id),
                    ),
                  ),
                );
              },
              itemCount: notes.length,
            ),
    );
  }
}
