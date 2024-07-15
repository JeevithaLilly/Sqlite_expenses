import 'package:flutter/material.dart';
import 'package:sqlite_example/view/AddNewItem.dart';
import 'package:sqlite_example/view/Dashboard.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFE1BEE7)),

      initialRoute: '/',
      routes: {
        '/':(context)=>SplashScreen(),
        '/addExpense':(context)=>ExpensesDetails(
          indexvalue: 0,
          date: "", id: 0
          ,

        )
      },

    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 000), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset("asset/images/dollar.png", width: 200, height: 200),
          ],
        ),
      ),
    );
  }
}


