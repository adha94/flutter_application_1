import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/model/firebase_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/count_products.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CountProductsBuffer extends StatefulWidget {
  final String date, value, productSelected;
  CountProductsBuffer(this.date, this.value, this.productSelected);

  @override
  State<CountProductsBuffer> createState() => _CountProductsBufferState();
}

class _CountProductsBufferState extends State<CountProductsBuffer> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String name = "";
  UploadTask? task;
  String _versionOpenCV = 'OpenCV';
  final openingFigureController = new TextEditingController();
  final closingFigureController = new TextEditingController();
  File? image;
  late File imageTemporary;
  String? message = "";
  String? urlDownload;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getOpenCVVersion();
    openingFigureController.text = "0";
    closingFigureController.text = "0";
  }

  Future<void> _getOpenCVVersion() async {
    String? versionOpenCV = await Cv2.version();
    setState(() {
      _versionOpenCV = 'OpenCV: ' + versionOpenCV!;
    });
  }

  Future pickGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
      });
      uploadImage();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
      });
      uploadImage();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  uploadImage() async {
    final request = http.MultipartRequest(
        "POST",
        Uri.parse(
            'https://d3cb-2001-e68-5408-7262-34e6-4f57-ae2f-1ab6.ngrok.io/upload'));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        imageTemporary.readAsBytes().asStream(), imageTemporary.lengthSync(),
        filename: '0.jpg'));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    print(message);
    setState(() {
      if (widget.value.toString() == "Opening") {
        openingFigureController.text = message!;
      } else {
        closingFigureController.text = message!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final openingField = TextFormField(
      autofocus: false,
      controller: openingFigureController,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        openingFigureController.text = value!;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    final closingField = TextFormField(
      autofocus: false,
      controller: closingFigureController,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        closingFigureController.text = value!;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Counting Products - Page 2"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CountProducts()));
          },
        ),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 20),
                                Text(
                                    'Date: ${widget.date} \nShift: ${widget.value} \nProduct: ${widget.productSelected}',
                                    style:
                                        TextStyle(fontSize: 16, height: 1.5)),
                                SizedBox(height: 16),
                                Text('Opening: ',
                                    style: TextStyle(fontSize: 16)),
                                openingField,
                                SizedBox(height: 16),
                                Text('Closing: ',
                                    style: TextStyle(fontSize: 16)),
                                closingField,
                                SizedBox(height: 16),
                                MaterialButton(
                                  height: 40,
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(0.05)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            elevation: 30,
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    pickCamera();
                                                  },
                                                  child:
                                                      Text('Pick from Camera')),
                                              TextButton(
                                                  onPressed: () {
                                                    pickGallery();
                                                  },
                                                  child: Text(
                                                      'Pick from Gallery')),
                                            ],
                                          );
                                        });
                                  },
                                  child: Text(
                                    "Let's Start Counting!",
                                  ),
                                ),
                                SizedBox(height: 10),
                                MaterialButton(
                                  height: 40,
                                  color: Colors.deepOrange,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(0.05)),
                                  onPressed: () async {
                                    int opening =
                                        int.parse(openingFigureController.text);
                                    int closing =
                                        int.parse(closingFigureController.text);
                                    int variance = opening - closing;

                                    if (widget.value.toString() == "Opening") {
                                      addOpeningQty(widget.date,
                                          widget.productSelected, opening);
                                    } else if (widget.value.toString() ==
                                        "Closing") {
                                      addClosingQty(
                                          widget.date,
                                          widget.productSelected,
                                          closing,
                                          variance);
                                    }
                                  },
                                  child: Text(
                                    "ADD TO INVENTORY",
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 0, right: 0),
                                    child: Text(
                                      _versionOpenCV,
                                      style: TextStyle(fontSize: 10),
                                    )),
                              ])))))),
    );
  }

  void addOpeningQty(String date, String product, int opening) async {
    try {
      firebaseFirestore.collection('inventory').add({
        "date": date,
        "product": product,
        "opening": opening,
      }).then((value) {
        Fluttertoast.showToast(
            msg: "Product counted successfully for the opening shift!");
        openingFigureController.clear();
      });
    } catch (e) {
      throw Fluttertoast.showToast(msg: e.toString());
    }
  }

  void addClosingQty(
      String date, String product, int closing, int variance) async {
    try {
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('inventory')
          .where("date", isEqualTo: "$date")
          .where("product", isEqualTo: "$product")
          .get();
      QueryDocumentSnapshot queryDocumentSnapshot = querySnapshot.docs[0];
      DocumentReference documentReference = queryDocumentSnapshot.reference;
      await documentReference.update({"closing": closing}).then((value) {
        Fluttertoast.showToast(
            msg: "Product counted successfully for the day.");
        closingFigureController.clear();
      });
    } catch (e) {
      throw Fluttertoast.showToast(msg: e.toString());
    }
  }
}
