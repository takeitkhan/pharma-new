import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'Provider/profile_provider.dart';
import 'Utils/custom_loading.dart';
import 'View/Auth/Verification.dart';
import 'CustomNav.dart';

class MiddleOfHomeAndSignIn extends StatefulWidget {
  const MiddleOfHomeAndSignIn({Key? key}) : super(key: key);

  @override
  _MiddleOfHomeAndSignInState createState() => _MiddleOfHomeAndSignInState();
}

class _MiddleOfHomeAndSignInState extends State<MiddleOfHomeAndSignIn> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingWidget();
        }

        if (snapshot.data != null && snapshot.data!.emailVerified) {
          return const CustomNavigation();
        }

        return snapshot.data == null
            ? const CustomNavigation()
            : const Verification();
      },
    );
  }
}
