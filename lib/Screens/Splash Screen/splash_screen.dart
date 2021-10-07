import 'package:flutter/material.dart';

import '../../Models/loader.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Loader(),
    );
  }
}
