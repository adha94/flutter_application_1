import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/screens/count_products.dart';
import 'package:flutter_application_1/screens/inventory_report.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/view_products.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _myDateTime;
  String time = '?';
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automated Inventory Counting"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome,",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${loggedInUser.fullName}",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ActionChip(
                    label: Text("Logout"),
                    onPressed: () {
                      logout(context);
                    }),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ViewProducts()));
                  },
                  child: Text("View Products"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.purpleAccent,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.all(20.0)),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => CountProducts()));
                  },
                  child: Text("Count Products"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.purpleAccent,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.all(20.0)),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    _myDateTime = await showDatePicker(
                        context: context,
                        initialDate:
                            _myDateTime == null ? DateTime.now() : _myDateTime!,
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2050));
                    setState(() {
                      time = DateFormat('dd-MM-yyyy').format(_myDateTime!);
                      proceedToNextPage(time);
                    });
                  },
                  child: Text("Inventory Report"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.purpleAccent,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.all(20.0)),
                )
              ]),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  proceedToNextPage(String time) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InventoryReport(
                  time,
                )));
  }
}
