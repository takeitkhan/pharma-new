import 'package:flutter/material.dart';
import 'package:pharma/View/Auth/widgets/SnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This function is now async and returns the allowed domains
Future<List<String>> getAllowedDomains() async {
  try {
    var querySnapshot = await FirebaseFirestore.instance.collection('allowedDomains').get();
    List<String> domains = [];
    for (var doc in querySnapshot.docs) {
      domains.add(doc['domain']);
    }
    return domains;
  } catch (e) {
    print('Error fetching allowed domains: $e');
    return [];
  }
}

Center customTextField(
    TextEditingController controller,
    String text,
    BuildContext context,
    IconData iconData, {
      bool skipNameValidation = false, // Define the named parameter here
    }) {
  return Center(
    child: TextFormField(
      controller: controller,
      keyboardAppearance: Brightness.light,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: text,
        fillColor: Color(0xffC4C4C4).withOpacity(0.2),
        filled: true,
        suffixIcon: Icon(iconData),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        // Full name validation with skipNameValidation logic
        if (text == "Full name" && !skipNameValidation) {
          if (value != null && value.length > 50) {
            snackBar(context, "Name should be less than 50 characters");
            return "Name should be less than 50 characters";
          } else if (value == null || value.isEmpty) {
            snackBar(context, "Field cannot be empty!");
            return "Field cannot be empty!";
          } else if (isNameValid(value)) {
            snackBar(context, "Name should contain only characters");
            return "Name should contain only characters";
          }
        } else if (text == "NHS email") {
          if (value == null || value.isEmpty) {
            snackBar(context, "Field cannot be empty!");
            return "Field cannot be empty!";
          }
          // Perform the domain check outside the validator
          _checkEmailDomain(value, context);
        } else if (text == "Password" || text == "Confirm Password") {
          if (value == null || value.isEmpty) {
            snackBar(context, "Field cannot be empty!");
            return "Field cannot be empty!";
          } else if (value.length < 6) {
            snackBar(context, "Password should be at least 6 characters long");
            return "Password should be at least 6 characters long";
          }
        } else if (text == "ODS Code") {
          if (value == null || value.isEmpty) {
            snackBar(context, "Field cannot be empty!");
            return "Field cannot be empty!";
          }
        }
        return null;
      },
      obscureText: text == "Password" || text == "Confirm Password" ? true : false,
    ),
  );
}


// Function to check the email domain asynchronously
Future<void> _checkEmailDomain(String email, BuildContext context) async {
  List<String> allowedDomains = await getAllowedDomains();

  bool isValidDomain = allowedDomains.any((domain) => email.endsWith('@' + domain));

  if (!isValidDomain) {
    snackBar(context, "You have to use an email address from an allowed domain");
  }
}

bool isNameValid(String name) {
  if (name.isEmpty) {
    return false;
  }
  bool hasDigits = name.contains(RegExp(r'[0-9]'));
  bool hasSpecialCharacters = name.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  return hasDigits || hasSpecialCharacters;
}
