import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File imageTemporary) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(imageTemporary);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
