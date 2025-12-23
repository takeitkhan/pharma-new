import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Provider/profile_provider.dart';
import '../Profile/SubPage/ProfileDetail.dart';

//// >>> ADDED FOR APPLE ATT
import '../../att_service.dart';
//// <<< END ATT ADDITION

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //// >>> ADDED FOR APPLE ATT
  bool trackingAllowed = false;
  //// <<< END ATT ADDITION

  WebViewController? controller;

  @override
  void initState() {
    super.initState();

    //// >>> ADDED FOR APPLE ATT
    _initATT();
    //// <<< END ATT ADDITION
  }

  //// >>> ADDED FOR APPLE ATT
  Future<void> _initATT() async {
    // Request permission from iOS
    trackingAllowed = await ATTService.requestPermission();

    // Create WebView controller AFTER permission result
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            if (!trackingAllowed) {
              _blockTrackingCookies();
            }
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://leicestershire-rutland.communitypharmacy.org.uk/'),
      );

    setState(() {});
  }
  //// <<< END ATT ADDITION

  //// >>> ADDED FOR APPLE ATT (Cookie blocker)
  void _blockTrackingCookies() {
    controller?.runJavaScript("""
      document.cookie.split(";").forEach(function(cookie) {
        if (cookie.includes("_fbp") ||
            cookie.includes("_ga") ||
            cookie.includes("_gcl") ||
            cookie.includes("ads") ||
            cookie.includes("fr"))
        {
            document.cookie = cookie.replace(/^ +/, "")
              .replace(/=.*/, "=;expires=Thu, 01 Jan 1970 00:00:00 GMT");
        }
      });

      if (typeof fbq !== "undefined") fbq = function() {};
      if (window.dataLayer) window.dataLayer = [];
    """);
  }
  //// <<< END ATT ADDITION

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<ProfileProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                if (!pro.isProfileComplete)
                  Container(
                    height: 50.h,
                    width: 360.w,
                    color: Colors.yellow,
                    child: Row(
                      children: [
                        SizedBox(width: 20.w),
                        Text(
                          "Please complete your profile",
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfileDetails()));
                          },
                          child: Text(
                            "Start",
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                      ],
                    ),
                  ),

                Expanded(
                  child: controller == null
                      ? Center(child: CircularProgressIndicator())
                      : WebViewWidget(controller: controller!),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
