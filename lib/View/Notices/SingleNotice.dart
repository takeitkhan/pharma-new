import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Utils/app_colors.dart';

class SingleNotice extends StatefulWidget {
  final String noticeId; // Add noticeId as a parameter
  final String databaseName; // Add databaseName as a parameter

  const SingleNotice({Key? key, required this.noticeId, required this.databaseName})
      : super(key: key); // Constructor

  @override
  State<SingleNotice> createState() => _SingleNoticeState();
}

class _SingleNoticeState extends State<SingleNotice> {
  Map<String, dynamic> payload = {};
  DocumentSnapshot? notice; // To hold the notice data

  @override
  void initState() {
    super.initState();
    _fetchNotice(); // Fetch notice data on initialization
  }

  // Fetch notice details from Firestore
  Future<void> _fetchNotice() async {
    try {
      print("Fetching notice for: ${widget.noticeId} from ${widget.databaseName}");  // Debugging log
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(widget.databaseName) // Use databaseName
          .doc(widget.noticeId) // Use noticeId
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          notice = doc; // Store the notice data
          payload = doc.data() as Map<String, dynamic>; // Convert data to Map
        });
        print("Notice fetched successfully: $payload");  // Debugging log
      } else {
        // Handle case where notice doesn't exist
        print("Notice not found!"); // Debugging log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice not found')),
        );
      }
    } catch (e) {
      // Handle errors
      print("Error fetching notice: $e");  // Debugging log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notice: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Notice Detail",
          style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: notice == null // Show loading or notice details
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: _buildNoticeCard(),
        ),
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Card(
      color: offWhite, // Set your desired background color here
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.title, "Title", payload['postTitle'] ?? "N/A"),
            SizedBox(height: 12.h),
            _buildInfoRow(
              Icons.lock_clock_rounded,
              "Created",
              payload['dateTime'] != null
                  ? DateFormat('dd-MM-yyyy').format(DateTime.parse(payload['dateTime']))
                  : "N/A", // Correct date formatting and fallback
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.description, "Description", payload['postText'] ?? "No description available."),
          ],
        ),
      ),
    );
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
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                content,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
