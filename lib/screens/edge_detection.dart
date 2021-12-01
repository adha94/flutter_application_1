import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/count_products_buffer.dart';
import 'package:image_picker/image_picker.dart';

class EdgeDetection extends StatefulWidget {
  const EdgeDetection({Key? key}) : super(key: key);

  @override
  _EdgeDetectionState createState() => _EdgeDetectionState();
}

class _EdgeDetectionState extends State<EdgeDetection> {
  late String date, value, productSelected;
  File? image;
  String? imgURL;
  var task;
  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Edge Detection in Action"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CountProductsBuffer(date, value, productSelected)));
            },
          ),
        ),
        //body: Colu,
      ),
    );
  }
}
