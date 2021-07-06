import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import './auth_form.dart';

import '../../Models/routes.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _showError(BuildContext ctx, String msg) {
    Scaffold.of(ctx).hideCurrentSnackBar();
    if (msg != null)
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
  }

  Future<void> _submitAuthForm(
    String name,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    setState(() {
      _isLoading = true;
    });

    AuthResult authResult;
    final email = '$username@app.com';

    try {
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .collection('profile')
            .add({
          'name': name,
          'username': username,
        });
      }
      _showError(ctx, null);
      Navigator.of(context).pushReplacementNamed(Routes.expenses_screen);
    } on PlatformException catch (err) {
      var msg = "An error occurred. Please check your credentials!";

      if (err.message != null) {
        msg = err.message;
        if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
          msg = "This username is taken. Try another one.";
        } else if (err.code == "ERROR_USER_NOT_FOUND") {
          msg = "No user registered with this username. Click create new account for register.";
        }
      }
      _showError(ctx, msg);
    } catch (err) {
      _showError(ctx, err);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: AuthForm(_isLoading, _submitAuthForm),
            ),
          ),
        ),
      ),
    );
  }
}
