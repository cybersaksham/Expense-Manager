import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

import '../../Models/loader.dart';

class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String,
    String,
    String,
    bool,
    BuildContext,
  ) authenticate;

  AuthForm(this.isLoading, this.authenticate);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  String _name = "";
  String _userName = "";
  String _password = "";

  String _validateName(String val) {
    if (val.isEmpty) {
      return "This field is required.";
    } else if (val.length <= 4) {
      return "Name must be atleast 5 characters long.";
    } else {
      List<String> nameList = val.split(" ");
      String msg;
      nameList.forEach((item) {
        if (!isAlpha(item)) msg = "Name can contain letters only.";
      });
      return msg;
    }
  }

  String _validatePassword(String val) {
    if (val.isEmpty) {
      return "This field is required.";
    } else if (val.length <= 7) {
      return "Password must be atleast 8 characters long.";
    }
    return null;
  }

  String _validateUsername(String val) {
    if (val.isEmpty) {
      return "This field is required.";
    } else if (val.length <= 4) {
      return "Username must be atleast 5 characters long.";
    } else if (!isAlphanumeric(val)) {
      return "Username can contain letters and numbers only.";
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      widget.authenticate(
        _name.trim(),
        _userName.trim(),
        _password.trim(),
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!_isLogin)
            TextFormField(
              key: ValueKey("Name"),
              decoration: InputDecoration(labelText: "Name"),
              validator: (val) => _validateName(val),
              textCapitalization: TextCapitalization.words,
              onSaved: (val) => _name = val,
            ),
          TextFormField(
            key: ValueKey("Username"),
            decoration: InputDecoration(labelText: "Username"),
            validator: (val) => _validateUsername(val),
            onSaved: (val) => _userName = val,
          ),
          TextFormField(
            key: ValueKey("Password"),
            decoration: InputDecoration(labelText: "Password"),
            validator: (val) => _validatePassword(val),
            obscureText: true,
            onSaved: (val) => _password = val,
          ),
          SizedBox(height: 10),
          if (widget.isLoading)
            Container(
              height: 95,
              child: Loader(),
            ),
          if (!widget.isLoading) ...[
            RaisedButton(
              child: Text(_isLogin ? "Login" : "Create"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: _submitForm,
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text(
                _isLogin ? "Create new account" : "Already have an account",
              ),
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            )
          ]
        ],
      ),
    );
  }
}
