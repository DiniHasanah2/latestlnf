import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? username;
  String? phoneNumber;
  Position? userPosition; // New field for storing user's position

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }

  void setUsername(String name) {
    username = name;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    phoneNumber = phone;
    notifyListeners();
  }

  void updateUser(String id, String name, String phone) {
    userId = id;
    username = name;
    phoneNumber = phone;
    notifyListeners();
  }

  // New method for updating user's position
  void updateUserPosition(Position position) {
    userPosition = position;
    notifyListeners();
  }
}
/*import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? username;
  String? phoneNumber;

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }

  void setUsername(String name) {
    username = name;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    phoneNumber = phone;
    notifyListeners();
  }

  void updateUser(String id, String name, String phone) {
    userId = id;
    username = name;
    phoneNumber = phone;
    notifyListeners();
  }
}*/















/*import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? userId;

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }
}*/
