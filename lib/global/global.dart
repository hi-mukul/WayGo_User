import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waygo/models/userModel.dart';

final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
User? currentUser;
userModel? userModleCurrentInfo;