import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

import '../Main Drawer/main_drawer.dart';
import './new_transaction.dart';
import './expense_detail.dart';

import '../../Models/loader.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  FirebaseUser _user;
  bool _isLoading = false;
  List<dynamic> _selectedTransactions = [];
  double _totalAmt = 0.0;
  String _dateFilter = "Select";
  String _monthFilter = "Select";
  String _yearFilter = "Select";
  bool _isMonthSelected = false;
  bool _isYearSelected = false;

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

  void addTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(),
        );
      },
    );
  }

  void showDetail(BuildContext ctx, dynamic tappedUser) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: ExpenseDetail(tappedUser),
        );
      },
    );
  }

  List<Map<String, String>> _dateSrc() {
    return List.generate(
      31,
      (index) {
        Map<String, String> myMap;
        myMap = {
          "display":
              (index + 1) < 10 ? "0${index + 1}" : (index + 1).toString(),
          "value": (index + 1) < 10 ? "0${index + 1}" : (index + 1).toString(),
        };
        return myMap;
      },
    ).toList();
  }

  List<Map<String, String>> _monthSrc() {
    Map<int, String> months = {
      0: "Jan",
      1: "Feb",
      2: "Mar",
      3: "Apr",
      4: "May",
      5: "Jun",
      6: "Jul",
      7: "Aug",
      8: "Sep",
      9: "Oct",
      10: "Nov",
      11: "Dec",
    };
    return List.generate(
      12,
      (index) {
        Map<String, String> myMap;
        myMap = {
          "display": months[index],
          "value": months[index],
        };
        return myMap;
      },
    ).toList();
  }

  List<Map<String, String>> _yearSrc() {
    return List.generate(
      DateTime.now().year - 2000,
      (index) {
        Map<String, String> myMap;
        myMap = {
          "display": (DateTime.now().year - index).toString(),
          "value": (DateTime.now().year - index).toString(),
        };
        return myMap;
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget dropDowns() {
      List filters = [
        Expanded(
          child: DropDownFormField(
            titleText: "Year",
            hintText: 'Select',
            value: _yearFilter,
            onChanged: (value) {
              setState(() {
                _yearFilter = value;
                _isYearSelected = true;
                _isMonthSelected = false;
                _monthFilter = "Select";
                _dateFilter = "Select";
                if (_yearFilter == "Select") {
                  _isYearSelected = false;
                }
              });
            },
            dataSource: [
              {
                'display': 'Select',
                'value': 'Select',
              },
              ..._yearSrc()
            ],
            textField: 'display',
            valueField: 'value',
          ),
        ),
        if (_isYearSelected)
          Expanded(
            child: DropDownFormField(
              titleText: "Month",
              hintText: 'Select',
              value: _monthFilter,
              onChanged: (value) {
                setState(() {
                  _monthFilter = value;
                  _isMonthSelected = true;
                  _dateFilter = "Select";
                  if (_monthFilter == "Select") _isMonthSelected = false;
                });
              },
              dataSource: [
                {
                  'display': 'Select',
                  'value': 'Select',
                },
                ..._monthSrc()
              ],
              textField: 'display',
              valueField: 'value',
            ),
          ),
        if (_isMonthSelected)
          Expanded(
            child: DropDownFormField(
              titleText: "Date",
              hintText: 'Select',
              value: _dateFilter,
              onChanged: (value) {
                setState(() {
                  _dateFilter = value;
                });
              },
              dataSource: [
                {
                  'display': 'Select',
                  'value': 'Select',
                },
                ..._dateSrc()
              ],
              textField: 'display',
              valueField: 'value',
            ),
          ),
      ];
      return Row(
        children: <Widget>[...filters],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Expenses"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addTransaction(context),
          ),
        ],
      ),
      drawer: MainDrawer("home"),
      body: _isLoading
          ? Loader()
          : Column(
              children: <Widget>[
                dropDowns(),
                Expanded(
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(_user.uid)
                          .collection('expenses')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }
                        List<dynamic> expenseData = snapshot.data.documents;
                        final selectedDate =
                            "$_monthFilter $_dateFilter, $_yearFilter";
                        if (_yearFilter == "Select") {
                          _selectedTransactions = expenseData;
                        } else {
                          _selectedTransactions = [];
                          expenseData.forEach((tx) {
                            if (_monthFilter == "Select") {
                              if (tx['date'].substring(8) == _yearFilter) {
                                _selectedTransactions.add(tx);
                              }
                            } else {
                              if (_dateFilter == "Select") {
                                if (tx['date'].substring(8) == _yearFilter &&
                                    tx['date'].substring(0, 3) ==
                                        _monthFilter) {
                                  _selectedTransactions.add(tx);
                                }
                              } else {
                                if (tx['date'] == selectedDate) {
                                  _selectedTransactions.add(tx);
                                }
                              }
                            }
                          });
                        }
                        _totalAmt = 0.0;
                        _selectedTransactions.forEach((tx) {
                          _totalAmt += double.parse(tx['amount']);
                        });
                        return _selectedTransactions.length == 0
                            ? Center(
                                child: Text(
                                  "No transaction available",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              )
                            : Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: ListTile(
                                      leading: Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      trailing: CircleAvatar(
                                        radius: 25,
                                        child: Padding(
                                          padding: EdgeInsets.all(6),
                                          child: FittedBox(
                                            child: Text(
                                              _totalAmt.toStringAsFixed(0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _selectedTransactions.length,
                                      itemBuilder: (ctx, i) {
                                        return InkWell(
                                          onTap: () => showDetail(context,
                                              _selectedTransactions[i]),
                                          child: Dismissible(
                                            key: ValueKey(_user.uid),
                                            background: Container(
                                              color:
                                                  Theme.of(context).errorColor,
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              alignment: Alignment.centerRight,
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              margin: EdgeInsets.symmetric(
                                                vertical: 4,
                                                horizontal: 15,
                                              ),
                                            ),
                                            direction:
                                                DismissDirection.endToStart,
                                            confirmDismiss: (dir) {
                                              return showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text("Are you sure?"),
                                                  content: Text(
                                                    "Do you want to remove this expense?",
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.of(ctx)
                                                            .pop(false);
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        Navigator.of(ctx)
                                                            .pop(true);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            onDismissed: (dir) {
                                              setState(() {
                                                Firestore.instance
                                                    .collection('users')
                                                    .document(_user.uid)
                                                    .collection('expenses')
                                                    .document(
                                                        _selectedTransactions[i]
                                                                ['createdAt']
                                                            .toString())
                                                    .delete();
                                              });
                                            },
                                            child: Card(
                                              elevation: 5,
                                              margin: EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 5,
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(6),
                                                    child: FittedBox(
                                                      child: Text(
                                                          _selectedTransactions[
                                                              i]['amount']),
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  _selectedTransactions[i]
                                                      ['title'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      .copyWith(fontSize: 17),
                                                ),
                                                subtitle: Text(
                                                  _selectedTransactions[i]
                                                      ['date'],
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                      }),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => addTransaction(context),
      ),
    );
  }
}
