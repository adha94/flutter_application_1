import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/view_products.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';

class EditProducts extends StatefulWidget {
  const EditProducts(QueryDocumentSnapshot<Object?> product, {Key? key})
      : super(key: key);

  @override
  _EditProductsState createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  @override
  Widget build(BuildContext context) {
    final Object? todo = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit a Product"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewProducts()));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Text(todo.toString()),
      ),
    );
  }
}
