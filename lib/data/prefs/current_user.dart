import 'share_prefs.dart';

class CurrentUser extends Prefs {
  final userID = 'userID';
  final userName = 'userName';
  final employeeID = 'skillId';
  final token = 'token';
  final role = 'role';
  final isFromProfile = 'fromProfile';
  final isEdit = 'isEdit';
  final isVerified = 'isVerified';
  final isCompleted = 'isCompleted';
  final lat = 'lat';
  final long = 'long';
  final address = 'address';
  final email = 'email';
  final password = 'password';
  final fName = 'fName';
  final lName = 'lName';
  final isOnboarding = 'isOnboarding';
  final userModel = 'userModel';
  static final CurrentUser _instance = CurrentUser();

  CurrentUser() {
    Prefs.init();
  }

  static Future<CurrentUser> getInstance() async {
    await Prefs.init();
    return _instance;
  }

  setUserId(String value) {
    Prefs.setString(userID, value);
  }


  setUserName(String value) {
    Prefs.setString(userName, value);
  }

  String get getUserId {
    return Prefs.getString(userID);
  }

  String get getUserName {
    return Prefs.getString(userName);
  }


  setAddress(Map<String, dynamic> address) {
    Prefs.setMap('address', address);  // Store address as JSON string
  }

  Map<String, dynamic> get getAddress {
    return Prefs.getMap('address');  // Retrieve address as Map
  }

  setLatitude(String value) {
    Prefs.setString(lat, value);
  }

  String get getLatitude {
    return Prefs.getString(lat);
  }

  setLongitude(String value) {
    Prefs.setString(long, value);
  }

  String get getLongitude {
    return Prefs.getString(long);
  }

  setToken(String value) {
    Prefs.setString(token, value);
  }

  String get getToken {
    return Prefs.getString(token);
  }

  setEmail(String value) {
    Prefs.setString(email, value);
  }

  String get getEmail {
    return Prefs.getString(email);
  }

  setPassword(String value) {
    Prefs.setString(password, value);
  }

  String get getPassword {
    return Prefs.getString(password);
  }

  setFName(String value) {
    Prefs.setString(fName, value);
  }

  String get getFName {
    return Prefs.getString(fName);
  }

  setLName(String value) {
    Prefs.setString(lName, value);
  }

  String get getLName {
    return Prefs.getString(lName);
  }

  setIsVerified(bool value) {
    Prefs.setBool(isVerified, value);
  }

  bool get getIsVerified {
    return Prefs.getBool(isVerified);
  }

  setIsCompleted(bool value) {
    Prefs.setBool(isCompleted, value);
  }

  bool get getIsCompleted {
    return Prefs.getBool(isCompleted);
  }

  setEmployeeId(String value) {
    Prefs.setString(employeeID, value);
  }

  String get getEmployeeId {
    return Prefs.getString(employeeID);
  }

  setFromProfile(bool value) {
    Prefs.setBool(isFromProfile, value);
  }

  bool get getFromProfile {
    return Prefs.getBool(isFromProfile);
  }

  setIsEdit(bool value) {
    Prefs.setBool(isEdit, value);
  }

  bool get getIsEdit {
    return Prefs.getBool(isEdit);
  }

  setRole(String value) {
    Prefs.setString(role, value);
  }

  String get getRole {
    return Prefs.getString(role);
  }

  setIsOnboarding(bool value) {
    Prefs.setBool(isOnboarding, value);
  }

  bool get getIsOnboarding {
    return Prefs.getBool(isOnboarding);
  }

  logout() {
    Prefs.clearAll();
  }
}
