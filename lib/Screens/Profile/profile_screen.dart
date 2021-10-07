import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/loader.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseUser _user;
  bool _isLoading = false;

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    _user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: _isLoading
          ? Loader()
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(_user.uid)
                  .collection('profile')
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loader();
                }
                final profileData = snapshot.data.documents;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Name",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            profileData[0]['name'],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Username",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            profileData[0]['username'],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
