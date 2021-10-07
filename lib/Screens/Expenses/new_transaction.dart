import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Models/loader.dart';

class NewTransaction extends StatefulWidget {
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _formKey = GlobalKey<FormState>();
  bool _isDateSelected = false;
  bool _isLoading = false;
  DateTime _pickedDate;

  String _title = "";
  String _amount = "";
  String _description = "";
  String _date = "";

  String _validateTitle(String val) {
    if (val.isEmpty) return "This field is required.";
    return null;
  }

  String _validateAmt(String val) {
    if (val.isEmpty) return "This field is required.";
    if (!isNumeric(val)) return "Invalid amount";
    return null;
  }

  String _validateDate(String val) {
    if (!_isDateSelected) return "This field is required.";
    return null;
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      print("HI");
      setState(() {
        _isDateSelected = true;
        _pickedDate = pickedDate;
        _date = DateFormat('MMM dd, yyyy').format(pickedDate);
      });
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String year = (_date.trim()).substring(8);
      int month = _pickedDate.month;
      String day = (_date.trim()).substring(4, 6);
      String time = "$year $month $day ${Timestamp.now()}";
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('expenses')
          .document(time)
          .setData({
        'title': _title.trim(),
        'amount': _amount.trim(),
        'description': _description.trim(),
        'date': _date.trim(),
        'createdAt': time,
      });
      setState(() {
        _isLoading = true;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 70,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                onSaved: (val) => _title = val,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (val) => _validateTitle(val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Amount (in Rs.)"),
                onSaved: (val) => _amount = val,
                validator: (val) => _validateAmt(val),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                onSaved: (val) => _description = val,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: _isDateSelected ? _date : "Select Date",
                      ),
                      validator: (val) => _validateDate(val),
                      readOnly: true,
                      onTap: () => _presentDatePicker(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _presentDatePicker(),
                  )
                ],
              ),
              SizedBox(height: 30),
              if (_isLoading) Loader(),
              if (!_isLoading)
                RaisedButton(
                  child: Text("Add Transaction"),
                  onPressed: () => _submitForm(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
