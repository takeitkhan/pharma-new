import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Ensure you have the correct path to your SnackBar widget
import '../View/Auth/widgets/SnackBar.dart';

// The Authentication class must extend ChangeNotifier to use notifyListeners()
class Authentication with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to track auth state changes
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  // Sign in function (Already correct)
  Future<String> signIn(
      String email, String password, BuildContext context) async {
    try {
      var user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await FirebaseMessaging.instance.getToken();
      FirebaseFirestore.instance.collection("users").doc(user.user?.uid).update(
        {
          "token": token,
        },
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      print(e);
      print(e.code);
      print("-------------------------------------------- e.code");
      switch (e.code) {
        case "invalid-email":
          return "Your email address appears to be malformed";
        case "wrong-password":
          return "Wrong password";
        case "user-not-found":
          return "User with this email doesn\'t exist";
        case "user-disabled":
          return "User with this email has been disabled";
        case "invalid-credential":
          return "Invalid credential";
        default:
          return "An undefined error occurred";
      }
    } catch (e) {
      return "An error occurred.";
    }
  }



  // Sign up function (Corrected to return Future<String> as required)
  
Future<String> signUp({
    required String name,
    required String email,
    required String password,
    required String fCode,
    required context,
    bool isRegistration = true,
  }) async {
    try {
      // 1. Await the creation process instead of using .then/.catchError for better async flow
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context, rootNavigator: true).pop();
      if (isRegistration) {
        Navigator.of(context).pushReplacementNamed("MiddleOfHomeAndSignIn");
      }
      
      final token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "name": name,
        "email": userCredential.user!.email,
        "url": "",
        "role": fCode.isEmpty ? "" : "contractor",
        "token": token,
      });

      return "Success";
      
    } on FirebaseAuthException catch (e) { // CATCH BLOCK 1: Handles FirebaseAuth specific errors
      Navigator.of(context, rootNavigator: true).pop();
      switch (e.code) {
        case "weak-password":
          snackBar(context, "Your password is too weak.");
          return "Your password is too weak."; // Must return a value
        case "invalid-email":
          snackBar(context, "Your email is invalid.");
          return "Your email is invalid.";
        case "email-already-in-use":
          snackBar(context, "Email is already in use on a different account.");
          return "Email is already in use on a different account.";
        default:
          snackBar(context, "An undefined error occurred.");
          return "An undefined error occurred.";
      }
    } catch (error) { // CATCH BLOCK 2: Handles all other errors
      Navigator.of(context, rootNavigator: true).pop();
      snackBar(context, "An error occurred during sign-up.");
      return "An error occurred.";
    }
  }

  // Create user with secondary Firebase app
  Future<String> createUser({
    required String name,
    required String email,
    required String password,
    required String department,
    required String pharmacyId,
    required context,
    bool isRegistration = true,
  }) async {
    try { // <<-- ADDED 'try' BLOCK HERE
      // Use the secondary app for user creation
      //final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      //UserCredential credential = await auth.createUserWithEmailAndPassword(
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context, rootNavigator: true).pop();
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
        await FirebaseFirestore.instance // <<-- Added await
            .collection("users")
            .doc(credential.user!.uid)
            .set({
          "name": name,
          "email": credential.user!.email,
          "url": "",
          "role": "",
          "token": "",
        });
        await FirebaseFirestore.instance // <<-- Added await
            .collection("pharmacy")
            .doc(pharmacyId)
            .collection("pharmacies")
            .add({"pharmaciesId": credential.user!.uid});
      }

      // Delete the secondary app (consider keeping it if needed)
      //await secondaryApp.delete();
      return "Success";
    } on FirebaseAuthException catch (e) { // <<-- CATCH BLOCK 1 (Now correctly inside a try block)
      Navigator.of(context, rootNavigator: true).pop();
      switch (e.code) {
        case "weak-password":
          return "Your password is too weak.";
        case "invalid-email":
          return "Your email is invalid.";
        case "email-already-in-use":
          return "Email is already in use on a different account.";
        default:
          return "An undefined error occurred.";
      }
    } catch (e) { // <<-- CATCH BLOCK 2
      Navigator.of(context, rootNavigator: true).pop(); // Added pop on general error
      return "An error occurred.";
    }
  }

  // Sign out function (Needs no correction)
  Future signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  // Reset password (Needs no correction)
  Future<String> resetPassword(String email, BuildContext context) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Success";
    } catch (e) {
      return "Error";
    }
  }

  // Delete user (Needs no correction)
  Future deleteUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Delete data from Firestore
      await FirebaseFirestore.instance 
          .collection("users")
          .doc(user.uid)
          .delete();
      // Delete the user from Firebase Auth
      await user.delete(); 
      // Note: No notifyListeners() needed here unless you manage current user state outside of the stream
    }
  }
}
