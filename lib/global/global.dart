import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waygo/models/direction_details_info.dart';
import 'package:waygo/models/userModel.dart';

final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
User? currentUser;
userModel? userModleCurrentInfo;
DirectionDetailsInfo? tripDirectionDetailsInfo;

String userDropoffAddress = "";