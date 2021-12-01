import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/count_products_buffer.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:intl/intl.dart';

class CountProducts extends StatefulWidget {
  const CountProducts({Key? key}) : super(key: key);

  @override
  _CountProductsState createState() => _CountProductsState();
}

class _CountProductsState extends State<CountProducts> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  DateTime? _myDateTime;
  String time = '?';
  final shift = ['Opening', 'Closing'];
  String? value;
  String? productSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counting Products"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 24.0),
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
                });
              },
              child: Text('Select a date'),
            ),
            DropdownButton<String>(
              value: value,
              iconSize: 20,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              items: shift.map(buildMenuItem).toList(),
              onChanged: (value) => setState(
                () => this.value = value,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('itemName')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((product) {
                      return Container(
                          key: Key(product['itemName']),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5.0),
                            title: Text(product['itemName']),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(product['brand']),
                                Text(product['weight']),
                              ],
                            ),
                            onLongPress: () {},
                            onTap: () {
                              productSelected = product['itemName'];
                            },
                            selectedTileColor: Colors.teal,
                          ));
                    }).toList(),
                  );
                },
              ),
            ),
            MaterialButton(
              height: 40,
              color: Colors.blueAccent,
              //minWidth: 15,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.05)),
              onPressed: () {
                proceedToNextPage(time, value!, productSelected!);
              },
              child: Text(
                "Next",
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      );

  proceedToNextPage(String time, String value, String productSelected) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CountProductsBuffer(time, value, productSelected)));
  }
}
