import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import './chart.dart';

import '../../Models/loader.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  FirebaseUser _user;
  bool _isLoading = false;
  List<dynamic> _recentTransactions;
  List<dynamic> _recentTransactionsYear;
  List<dynamic> _recentTransactionsMonth;
  List<dynamic> _recentTransactionsDate;
  double _totalSum = 0.0;

  Map<String, String> get _amounts {
    double yearSum = 0.0;
    double monthSum = 0.0;
    double dateSum = 0.0;

    _recentTransactionsYear.forEach((tx) {
      yearSum += double.parse(tx['amount']);
    });
    _recentTransactionsMonth.forEach((tx) {
      monthSum += double.parse(tx['amount']);
    });
    _recentTransactionsDate.forEach((tx) {
      dateSum += double.parse(tx['amount']);
    });

    return {
      'year': yearSum.toStringAsFixed(0),
      'month': monthSum.toStringAsFixed(0),
      'date': dateSum.toStringAsFixed(0),
    };
  }

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
    Widget _rowStats(String head, String tail) {
      return Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "$head",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Rs. $tail",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stats"),
      ),
      body: _isLoading
          ? Loader()
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(_user.uid)
                  .collection('expenses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loader();
                }
                final expenseData = snapshot.data.documents;
                _recentTransactions = expenseData.where((tx) {
                  return DateFormat.yMMMd()
                      .parse(tx['date'] as String)
                      .isAfter(DateTime.now().subtract(Duration(days: 7)));
                }).toList();
                final curDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
                _recentTransactionsYear = expenseData.where((tx) {
                  return (tx['date'] as String).substring(8) ==
                      curDate.substring(8);
                }).toList();
                _recentTransactionsMonth = _recentTransactionsYear.where((tx) {
                  return (tx['date'] as String).substring(0, 3) ==
                      curDate.substring(0, 3);
                }).toList();
                _recentTransactionsDate = _recentTransactionsMonth.where((tx) {
                  return (tx['date'] as String).substring(4, 6) ==
                      curDate.substring(4, 6);
                }).toList();
                expenseData.forEach((tx) {
                  _totalSum += double.parse(tx['amount'] as String);
                });
                return Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Chart(_recentTransactions),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 35,
                      ),
                      child: Column(
                        children: <Widget>[
                          _rowStats(
                            "Year ${curDate.substring(8)}",
                            _amounts['year'],
                          ),
                          _rowStats(
                            "Month ${curDate.substring(0, 3)}",
                            _amounts['month'],
                          ),
                          _rowStats(
                            "Date ${curDate.substring(4, 6)}",
                            _amounts['date'],
                          ),
                          _rowStats(
                            "Total",
                            _totalSum.toStringAsFixed(0),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
