import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String? uid;
  String? employeeID;
  String? fullName;

  UserModel({this.uid, this.employeeID, this.fullName});

  //receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      employeeID: map['employeeID'],
      fullName: map['fullName'],
    );
  }

  //sending data to the server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'employeeID': employeeID,
      'fullName': fullName,
    };
  }
}
