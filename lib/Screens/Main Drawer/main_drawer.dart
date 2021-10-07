import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Models/routes.dart';

class MainDrawer extends StatefulWidget {
  final String pageIndex;

  MainDrawer(this.pageIndex);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    Icon iconData(var iconType) {
      return Icon(
        iconType,
        color: Theme.of(context).primaryColor,
      );
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("My Expenses"),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: iconData(Icons.account_balance_wallet),
            title: Text(
              "My Expenses",
              style: TextStyle(
                  color: widget.pageIndex == "home"
                      ? Theme.of(context).accentColor
                      : Colors.black),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(Routes.expenses_screen);
            },
          ),
          Divider(),
          ListTile(
            leading: iconData(Icons.bar_chart),
            title: Text(
              "Stats",
              style: TextStyle(
                  color: widget.pageIndex == "stats"
                      ? Theme.of(context).accentColor
                      : Colors.black),
            ),
            onTap: () {
              Navigator.of(context).popAndPushNamed(Routes.stats_screen);
            },
          ),
          Divider(),
          ListTile(
            leading: iconData(Icons.account_circle),
            title: Text(
              "Profile",
              style: TextStyle(
                  color: widget.pageIndex == "profile"
                      ? Theme.of(context).accentColor
                      : Colors.black),
            ),
            onTap: () {
              Navigator.of(context).popAndPushNamed(Routes.profile_screen);
            },
          ),
          Divider(),
          ListTile(
            leading: iconData(Icons.logout),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(Routes.auth_screen);
            },
          ),
        ],
      ),
    );
  }
}
