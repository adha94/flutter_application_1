import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/view_products.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'dart:io';
import 'dart:io' as io;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:form_field_validator/form_field_validator.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({Key? key}) : super(key: key);

  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  bool get weightUnit => true;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  // FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final TextEditingController brandController = new TextEditingController();
  final TextEditingController itemNameController = new TextEditingController();
  final TextEditingController weightController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  File? image;
  String? imgURL;
  var task;
  bool loader = false;

  Future pickGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandField = TextFormField(
        autofocus: false,
        controller: brandController,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          brandController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Brand",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Please specify the brand.";
        });
    final itemNameField = TextFormField(
        autofocus: false,
        controller: itemNameController,
        keyboardType: TextInputType.text,
        maxLines: 2,
        onSaved: (value) {
          itemNameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Item Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Please specify the item name.";
        });
    final weightField = TextFormField(
      autofocus: false,
      controller: weightController,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        weightController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Weight",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value!.contains('g') ||
            value.contains('mg') ||
            value.contains('kg') ||
            value.contains('ml') ||
            value.contains('l')) {
          return null;
        } else {
          return "Please input weight unit.";
        }
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Add a Product"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewProducts()));
          },
        ),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    image != null
                        ? Image.file(
                            image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : FlutterLogo(size: 100),
                    const SizedBox(height: 20),
                    buildButton(
                      title: 'Pick Gallery',
                      icon: Icons.image_outlined,
                      onClicked: () => pickGallery(),
                    ),
                    const SizedBox(height: 20),
                    buildButton(
                      title: 'Pick Camera',
                      icon: Icons.camera_alt_outlined,
                      onClicked: () => pickCamera(),
                    ),
                    SizedBox(height: 10),
                    brandField,
                    SizedBox(height: 10),
                    itemNameField,
                    SizedBox(height: 10),
                    weightField,
                    Spacer(),
                    this.loader == false
                        ? MaterialButton(
                            height: Get.size.height * 0.04,
                            color: Colors.blueAccent,
                            minWidth: Get.size.width * 0.5,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Get.size.height * 0.015)),
                            onPressed: () async {
                              this.setState(() {
                                this.loader = true;
                              });
                              firebase_storage.Reference storageRef =
                                  firebase_storage.FirebaseStorage.instance
                                      .ref()
                                      .child(DateTime.now().toString());
                              final uploadTask =
                                  firebase_storage.SettableMetadata(
                                      contentType: 'image/png',
                                      customMetadata: {
                                    'picked-file-path': image!.path
                                  });
                              firebase_storage.TaskSnapshot download =
                                  await storageRef.putFile(
                                      io.File(image!.path), uploadTask);

                              String url = await download.ref.getDownloadURL();
                              addProduct(
                                  brandController.text,
                                  itemNameController.text,
                                  weightController.text,
                                  url);
                              clearText();
                            },
                            child: Text(
                              "Add Product",
                            ),
                          )
                        : Center(child: CircularProgressIndicator()),
                    SizedBox(height: 10),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget buildButton({
    required String title,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(20),
          primary: Colors.white,
          onPrimary: Colors.black,
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 24),
            Text(title),
          ],
        ),
        onPressed: onClicked,
      );

  void addProduct(
      String brand, String itemName, String weight, String imageLink) async {
    print('imageLink');
    print(imageLink);
    if (_formKey.currentState!.validate()) {
      await firebaseFirestore.collection('products').add({
        "brand": brand,
        "itemName": itemName,
        "weight": weight,
        "imgURL": imageLink,
      }).then((value) {
        Fluttertoast.showToast(msg: "Product added successfully!");
        clearText();
        this.setState(() {
          this.loader = false;
        });
      });
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
  }

// Future<String?> uploadImageURL(String img) async {
//     var productImage = firebaseStorage.ref(img);
//     task = productImage.putFile(image!);
//     var imgURL = await task.ref.getDownloadURL();
//     return imgURL;
//   }

  void clearText() {
    brandController.clear();
    itemNameController.clear();
    weightController.clear();
  }

  Future<bool> checkIfProductExists(
      String brand, String itemName, String weight) async {
    try {
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('products')
          .where("brand", isEqualTo: "$brand")
          .where("itemName", isEqualTo: "$itemName")
          .where("weight", isEqualTo: "$weight")
          .get();
      QueryDocumentSnapshot queryDocumentSnapshot = querySnapshot.docs[0];
      DocumentReference documentReference = queryDocumentSnapshot.reference;
      if (documentReference == null) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      throw Fluttertoast.showToast(msg: e.toString());
    }
  }
}
