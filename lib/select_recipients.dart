import 'package:flutter/material.dart';
import 'confirmation.dart';

// Future<void> main() async {
//   runApp(
//     MaterialApp(
//       routes: <String, WidgetBuilder> {
//         '/confirmationScreen': (BuildContext context) =>
//         Confirmation()
//       }
//     ),
//   );
// }

class RecipientScreen extends StatefulWidget {
  // final String title;

  // ConfirmScreen({Key key, this.title}) : super(key: key);

  @override
  _RecipientScreen createState() => _RecipientScreen();
}

class _RecipientScreen extends State<RecipientScreen> {

  List _frames = ["Mom and Dad", "Grandpa", "Auntie", "Uncle Rajesh", "Aaron"];
  var _selectedID;
  var _selected = [];

  bool isSelected = false;
  Color currentColor = Colors.transparent;

  @override 
  Widget build (BuildContext context) {
    return StatefulBuilder (
      builder: (context, StateSetter setState) =>
        Scaffold(
          appBar: AppBar(
            title: Text('Select Recipients'),
          ),
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              var temp = _selected.contains(_frames[index]);
              return GestureDetector(
                onTap: () {
                  setState ( () {
                    _selectedID = _frames[index];
                  });
                  _toggleSelection(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: temp ? Colors.blue: Colors.transparent,
                      width: 2,
                    )
                  ),
                  child: ListTile(
                    selected: isSelected,
                    title: Text('${_frames[index]}'),
                  )
                )
              );
            }
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.arrow_right),
            onPressed: _confirmation
          ),
        )
    );
  }

   Future<void> _confirmation() async {
    var form = await Navigator.pushNamed(context, '/confirmationScreen');
  }

  void _toggleSelection(int id) {
    print("asdf");
    print("DEBUG: $_selected");
    print("DEBUG: ${_frames[id]}");
    setState(() {
      var indexSelected = false;
      if (_selected.contains(_frames[id])){
        // _selected.remove(_selected.indexOf(id));
        _selected.remove(_frames[id]);
      } else {
        
        _selected.add(_frames[id]);
      }
    });
  }
}