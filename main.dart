import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import './Screens/Expenses/expenses_screen.dart';
import './Screens/Authentication/auth_screen.dart';
import './Screens/Splash Screen/splash_screen.dart';
import './Screens/Profile/profile_screen.dart';
import './Screens/Stats/stats_screen.dart';

import './Models/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.pink,
        primaryColorBrightness: Brightness.dark,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.purple,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (userSnapshot.hasData) {
            return ExpensesScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        Routes.expenses_screen: (ctx) => ExpensesScreen(),
        Routes.auth_screen: (ctx) => AuthScreen(),
        Routes.profile_screen: (ctx) => ProfileScreen(),
        Routes.stats_screen: (ctx) => StatsScreen(),
      },
    );
  }
}
