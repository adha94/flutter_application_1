import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class InventoryReport extends StatefulWidget {
  const InventoryReport(this.time, {Key? key}) : super(key: key);
  final String time;

  @override
  _InventoryReportState createState() => _InventoryReportState();
}

class _InventoryReportState extends State<InventoryReport> {
  static late List<DisplayInventory> displayDataInChart = [];
  //get docs => null;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<DisplayInventory, String>> openingSeries = [
      charts.Series(
          data: displayDataInChart,
          id: "Opening",
          domainFn: (DisplayInventory d, _) => d.productName,
          measureFn: (DisplayInventory d, _) => d.openingFigure,
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault)
    ];
    List<charts.Series<DisplayInventory, String>> closingSeries = [
      charts.Series(
          data: displayDataInChart,
          id: "Closing",
          domainFn: (DisplayInventory d, _) => d.productName,
          measureFn: (DisplayInventory d, _) => d.closingFigure,
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Report"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
            .collection('inventory')
            .where("date", isEqualTo: widget.time)
            .snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    return Container(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5.0),
                        title: Text(documentSnapshot['product'],
                            style: TextStyle(fontSize: 16.0)),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "Opening: " +
                                    documentSnapshot['opening'].toString(),
                                style: TextStyle(fontSize: 16.0)),
                            Text(
                                "Closing: " +
                                    documentSnapshot['closing'].toString(),
                                style: TextStyle(fontSize: 16.0)),
                          ],
                        ),
                        trailing: IconButton(
                            icon: Icon(Icons.bar_chart, color: Colors.blue),
                            onPressed: () async {
                              displayDataInChart = [
                                documentSnapshot['product'],
                                documentSnapshot['opening'],
                                documentSnapshot['closing']
                              ];
                              Column(children: <Widget>[
                                charts.BarChart(openingSeries),
                                charts.BarChart(closingSeries)
                              ]);
                            }),
                      ),
                    );
                  });
        },
      ),
    );
  }
}

class DisplayInventory {
  final String productName;
  final int openingFigure;
  final int closingFigure;
  DisplayInventory(this.productName, this.openingFigure, this.closingFigure);
}
