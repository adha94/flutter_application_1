import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/add_products.dart';
import 'package:flutter_application_1/screens/edit_products.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';

/* Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ViewProducts());
} */

class ViewProducts extends StatefulWidget {
  const ViewProducts({Key? key}) : super(key: key);

  @override
  _ViewProductsState createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference documentReference =
      FirebaseFirestore.instance.collection('products');
  bool isEnabled = false;

  var searchController;
  get docs => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("View Products"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AddProducts()));
          },
        ),
        body: Container(
            child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a product",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
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
                    return Center(
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
                          trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await firebaseFirestore
                                    .collection('products')
                                    .doc(product.id)
                                    .delete();
                                setState(() {});
                                Fluttertoast.showToast(
                                    msg: "Product deleted successfully!");
                              }),
                        ));
                  }).toList(),
                );
              },
            ),
          )
        ])));
  }

  void removeItem(String getItemName) {}
}
