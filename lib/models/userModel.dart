

import 'package:firebase_database/firebase_database.dart';

class userModel{
  String? name;
  String? id;
  String? phone;
  String? email;
  String? address;

  userModel({
    this.email,
    this.phone,
    this.id,
    this.address,
    this.name,
  });

  userModel.fromSnapShot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["phone"];
    email = (snap.value as dynamic)["phone"];
    address = (snap.value as dynamic)["phone"];
    id=snap.key;
  }
}