import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:pharma/Utils/fcode.dart';
import 'package:pharma/View/Auth/widgets/RoundButton.dart';
import 'package:pharma/View/Auth/widgets/SnackBar.dart';
import 'package:pharma/View/Auth/widgets/SwitchPage.dart';
import 'package:pharma/View/Auth/widgets/TextField.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Provider/authentication.dart';
import '../../Utils/custom_loading.dart';

// Function to get the list of valid ODS codes from Firestore
Future<List<String>> getValidFcodes() async {
  try {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('fcodeList').get();
    List<String> fcodes = [];
    for (var doc in querySnapshot.docs) {
      fcodes.add(doc[
          'fcode']); // Assuming 'fcode' is the field name in your Firestore documents
    }
    return fcodes;
  } catch (e) {
    print('Error fetching ODS codes: $e');
    return [];
  }
}

// Function to get allowed domains asynchronously
Future<List<String>> getAllowedDomains() async {
  try {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('allowedDomains').get();
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

// Function to check the email domain asynchronously
Future<bool> _checkEmailDomain(String email, BuildContext context) async {
  List<String> allowedDomains = await getAllowedDomains();

  bool isValidDomain =
      allowedDomains.any((domain) => email.endsWith('@' + domain));

  if (!isValidDomain) {
    snackBar(
        context, "You have to use an email address from an allowed domain");
    return false;
  }
  return true;
}

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController fcodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  void dispose() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    fcodeController.clear();
    super.dispose();
  }

  validate() async {
    // Step 1: Validate the form first
    if (!_formKey.currentState!.validate()) {
      print("Invalid form");
      return; // If form is invalid, stop further execution
    }

    // Step 2: Check if the password matches
    if (confirmPasswordController.text != passwordController.text) {
      snackBar(context, "Password does not match");
      return; // Stop if passwords do not match
    }

    // Step 3: Validate ODS code if checkbox is checked
    if (isChecked) {
      List<String> validFcodes =
          await getValidFcodes(); // Fetch the valid ODS codes from Firestore
      if (!validFcodes.contains(fcodeController.text)) {
        snackBar(context, "Invalid ODS code");
        return; // Stop if the ODS code is not valid
      }
    }

    // Step 4: Asynchronously check email domain
    bool emailIsValid = await _checkEmailDomain(emailController.text, context);
    if (!emailIsValid) {
      return; // If email domain is invalid, stop the process
    }

    // Step 5: If all checks passed, proceed with registration
    try {
      buildLoadingIndicator(context); // Show loading indicator

      var result =
          await Provider.of<Authentication>(context, listen: false).signUp(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        fCode: fcodeController.text.isEmpty ? "" : fcodeController.text,
        context: context,
      );

      // Step 6: Handle sign-up result
      if (result != "Success") {
        snackBar(context, result); // Show error message if sign-up fails
      } else {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Send email verification only after successful sign-up
          await user.sendEmailVerification();
          snackBar(
              context, "Registration successful! Please verify your email.");
        }
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      snackBar(context, "Some error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(30.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 45.h),
              SizedBox(
                height: 150.h,
                child: Image.asset("assets/site_logo.jpeg"),
              ),
              SizedBox(height: 40.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    customTextField(nameController, "Full name", context,
                        Icons.person_outline_rounded),
                    SizedBox(height: 20.h),
                    customTextField(emailController, "NHS email", context,
                        Icons.email_outlined),
                    SizedBox(height: 20.h),
                    customTextField(passwordController, "Password", context,
                        Icons.lock_outline_rounded),
                    SizedBox(height: 20.h),
                    customTextField(
                        confirmPasswordController,
                        "Confirm Password",
                        context,
                        Icons.lock_outline_rounded),
                    SizedBox(height: 20.h),
                    switchPageButton(
                        "Already Have An Account? ", "Log In", context),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "Are you a contractor?",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).primaryColor),
                        ),
                        Checkbox(
                          tristate: true,
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "Yes",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    if (isChecked)
                      Row(
                        children: [
                          Text(
                            "Please provide your ODS code.",
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    if (isChecked) SizedBox(height: 20.h),
                    if (isChecked)
                      customTextField(fcodeController, "ODS Code", context,
                          Icons.password_outlined,
                          skipNameValidation: true),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  validate();
                },
                child: roundedButton("Register"),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
