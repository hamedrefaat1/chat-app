import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper{

  static String userIdkey="USERIDKEY";
  static String userNameKey="USERNAMEKEY";
  static String userEmailkey="USEREMAILKEY";
  static String userPickey="USERPICKEY";
   static String displayNameKey="DISPLAYNAMEKEY";

  Future<bool> saveUserId(String getUserId)async{
  SharedPreferences prefs= await SharedPreferences.getInstance();
  return prefs.setString(userIdkey, getUserId);
  }
    Future<bool> saveUserName(String getUserName)async{
  SharedPreferences prefs= await SharedPreferences.getInstance();
  return prefs.setString(userNameKey, getUserName);
  }

    Future<bool> saveDisplayrName(String getDisplayrName)async{
  SharedPreferences prefs= await SharedPreferences.getInstance();
  return prefs.setString(displayNameKey, getDisplayrName);
  }
    Future<bool> saveUserEmail(String getUserEmail)async{
  SharedPreferences prefs= await SharedPreferences.getInstance();
  return prefs.setString(userEmailkey, getUserEmail);
  }

   Future<bool> saveUserPic(String getUserPic)async{
  SharedPreferences prefs= await SharedPreferences.getInstance();
  return prefs.setString(userPickey, getUserPic);
  }

Future<String?> getUserId()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userIdkey);
}
Future<String?> getUserName()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userNameKey);
}
Future<String?> getUserEmai()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userEmailkey);
}
Future<String?> getUserPic()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userPickey);
}

Future<String?> getDisplayName()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(displayNameKey);
}
}