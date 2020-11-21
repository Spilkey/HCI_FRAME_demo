import 'package:flutter/material.dart';

class Confirmation extends StatefulWidget {
  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmed!"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Images sent!"),
            RaisedButton(
              child: Text(
                "Press to undo. (5 seconds left)"
              ),
              onPressed: _selectRecipients
            ),
          ]
        ),
      )     
    );
  }
   Future<void> _selectRecipients() async {
    Navigator.pushNamed(context, '/recipientScreen');
  }
}