import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharma/Provider/chat_provider.dart';
import 'package:pharma/Provider/notice_provider.dart';
import 'package:pharma/Provider/post_provider.dart';
import 'package:pharma/Provider/search_provider.dart';
import 'package:pharma/Utils/push_notification.dart';
import 'package:pharma/View/Chat/HoldingPage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Provider/authentication.dart';
import 'Provider/pharmacy_provider.dart';
import 'Provider/profile_provider.dart';
import 'Provider/fcodelist_provider.dart';
import 'Provider/allowed_domains_provider.dart';
import 'Utils/app_colors.dart';
import 'View/Auth/Registration.dart';
import 'View/Auth/Signin.dart';
import 'View/Notices/SingleNotice.dart';
import 'View/profile/Profile.dart';

import 'initial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize Firebase only if no app exists yet
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Push notifications
  PushNotifications.init();
  PushNotifications.localNotiInit();

  FirebaseMessaging.instance.subscribeToTopic("notice");
  FirebaseMessaging.instance.subscribeToTopic("contractorNotice");

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.isNotEmpty) {
      final noticeId = message.data['noticeId'] ?? '';
      final databaseName = message.data['databaseName'] ?? 'notice';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          _showNoticeDialog(navigatorKey.currentContext!, noticeId, databaseName);
        }
      });
    }
  });

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PharmacyProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FcodelistProvider()),
        ChangeNotifierProvider(create: (_) => AllowedDomainsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Community Pharma Connect',
            theme: _buildTheme(Brightness.light),
            home: const MiddleOfHomeAndSignIn(),
            routes: {
              "SignIn": (ctx) => const SignIn(),
              "Registration": (ctx) => const Registration(),
              "MiddleOfHomeAndSignIn": (ctx) => const MiddleOfHomeAndSignIn(),
              "Profile": (ctx) => const Profile(),
              "/holdingPage": (ctx) => const HoldingPage(),
              "/singleNotice": (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                return SingleNotice(
                  noticeId: args?['noticeId'] ?? '',
                  databaseName: args?['databaseName'] ?? 'notice',
                );
              },
            },
          );
        },
      ),
    );
  }
}

void _showNoticeDialog(BuildContext context, String noticeId, String databaseName) {
  print("Debug: Received noticeId = $noticeId, databaseName = $databaseName"); // Debugging print statement

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Notice Details"),
        content: SingleChildScrollView( // Make content scrollable for elastic effect
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection(databaseName).doc(noticeId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notice not found."),
                    Text("Debug: Database Name = $databaseName"),
                    Text("Debug: Notice ID = $noticeId"),
                  ],
                );
              } else {
                // Access the notice data here
                var noticeData = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.title, "Title", noticeData['postTitle'] ?? "N/A"),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.lock_clock_rounded,
                      "Created",
                      noticeData['dateTime'] != null
                          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(noticeData['dateTime']))
                          : "N/A", // Correct date formatting and fallback
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(Icons.description, "Description", noticeData['postText'] ?? "No description available."),
                  ],
                );
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

Future<void> storeTokenInFirestore(String userId, String token) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'device_token': token,
    }, SetOptions(merge: true));
  } catch (e) {
    print('Error storing token: $e');
  }
}

Widget _buildInfoRow(IconData icon, String title, String content) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.grey, size: 24.sp),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                )),
            SizedBox(height: 5.h),
            Text(content,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify),
          ],
        ),
      ),
    ],
  );
}


ThemeData _buildTheme(Brightness brightness) {
  var baseTheme = ThemeData(
    brightness: brightness,
    primarySwatch: greenSwatch,
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme),
    primaryColor: const Color(0xff425C5A),
    scaffoldBackgroundColor: Colors.white,
  );
}
