import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Overall extends StatelessWidget {
  //final List<Transaction> recentTransactions;

  //Overall(this.recentTransactions);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: Theme.of(context).primaryColorLight,
        elevation: 5,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 5,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 30,
            child: Padding(
              padding: EdgeInsets.all(5),
              child:
                Icon( Icons.face, color: Colors.deepPurple,
              ),
          ),
          ),
          title: Text(
            'Current Temperature:',
            style: Theme.of(context).textTheme.title,
          ),
          subtitle: Text(
            '98.6 - temp val',
            style: Theme.of(context).textTheme.subtitle,
          ),
          /*trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).errorColor,
                        //onPressed: () {},
                        onPressed: () => deleteNote(notes[index].id),
                      ),*/
        ),
      ),
    );
  }
}
