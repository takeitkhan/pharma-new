import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharma/Utils/app_colors.dart';
import 'package:pharma/Utils/custom_loading.dart';
import 'package:pharma/View/Notices/AddNotice.dart';
import 'package:pharma/View/Notices/SingleNotice.dart';
import 'package:pharma/View/Notices/UpdateNotice.dart';
import 'package:provider/provider.dart';

import '../../Provider/notice_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/search_provider.dart';
import '../../Utils/search_bar.dart';

class LoggedInNotice extends StatefulWidget {
  const LoggedInNotice({Key? key}) : super(key: key);

  @override
  State<LoggedInNotice> createState() => _LoggedInNoticeState();
}

class _LoggedInNoticeState extends State<LoggedInNotice> {
  int size = 0;
  String page = "All Users";
  String databaseName = "notice";

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<ProfileProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Notice Board",
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        actions: [
          if (pro.role == "admin")
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 22.sp,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNotice(),
                    ),
                  );
                },
              ),
            )
        ],
      ),
      // floatingActionButton: pro.role == "admin"
      //     ? customFloatingActionButton(context, "Notice")
      //     : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Consumer<NoticeProvider>(builder: (context, provider, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(databaseName)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildLoadingWidget();
              }

              final data = snapshot.data;
              if (data != null) {
                size = data.size;
              }

              return _buildNotice(pro, data);
            },
          );
        }),
      ),
    );
  }

  SizedBox _buildNotice(ProfileProvider pro, QuerySnapshot<Object?>? data) {
    return SizedBox(
      height: 800.h,
      child: Column(
        children: [
          if (pro.role == "admin" || pro.role == "contractor")
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // "For All Users" button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        page = "All Users"; // Update the page variable
                        databaseName =
                        "notice"; // Set the database name for all users
                      });
                    },
                    child: Text(
                      "For All Users",
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        color:
                        page == "All Users" ? primaryColor : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w), // Spacing between buttons
                  // "For All Contractors" button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        page = "Contractors"; // Update the page variable
                        databaseName =
                        "contractorNotice"; // Set the database name for contractors
                      });
                    },
                    child: Text(
                      "For All Contractors",
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        color:
                        page == "Contractors" ? primaryColor : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: buildSearch(context, "notice"),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    String title = data?.docs[index]["postTitle"] ?? '';
                    if (title
                        .toLowerCase()
                        .contains(provider.noticeSearchText.toLowerCase())) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to SingleNotice with noticeId and databaseName
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleNotice(
                                noticeId: data!.docs[index].id,
                                // Pass the noticeId
                                databaseName:
                                databaseName, // Pass the current database name
                              ),
                            ),
                          );
                        },
                        child: _container(data, index, page), // Pass page here
                      );
                    }
                    return const SizedBox();
                  },
                  itemCount: size,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _container(QuerySnapshot<Object?>? data, int index, String page) {
    // Determine dbName based on the page variable
    String dbName;
    if (page == "All Users") {
      dbName = "notice";
    } else if (page == "Contractors") {
      dbName = "contractorNotice";
    } else {
      dbName = "notice"; // Default case if needed
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 15.h),
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: offWhite,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ashColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row for Title and Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${data?.docs[index]["postTitle"]}",
                  style: GoogleFonts.lato(
                      fontSize: 15.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (Provider.of<ProfileProvider>(context, listen: false).role == "admin")
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) {
                    if (data != null) {
                      if (value == 'update') {
                        _navigateToUpdateNotice(data.docs[index], dbName); // Pass dbName
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(data.docs[index].id, dbName); // Pass dbName
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No data available to perform this action')),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'update',
                      child: Text('Update'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 0.h),
          // Adding a bottom border between title and description
          Container(
            height: 0.8,
            color: ddGray,
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 10.h),
          ),
          Text(
            data?.docs[index]["postText"] ?? '',
            style: GoogleFonts.lato(fontSize: 15.sp, height: 1.4),
          ),
          SizedBox(height: 3.h),
          // Adding a bottom border between title and description
          Container(
            height: 0.8,
            color: ddGray,
            margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 10.h),
          ),
          Text(
            // Assuming the date is stored in the "dateTime" field as a string
            'Created: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data?.docs[index]["dateTime"] ?? ''))}',
            style: GoogleFonts.lato(
              color: semiBlack,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }



// Method to navigate to the update notice page
  void _navigateToUpdateNotice(QueryDocumentSnapshot<Object?> notice, dbName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateNoticePage(notice: notice, databaseName: dbName),
      ),
    );
  }

// Method to show confirmation dialog before deletion
  void _showDeleteConfirmationDialog(String noticeId, String dbName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this notice?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteNotice(noticeId, dbName); // Pass dbName to deleteNotice
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


// Method to delete notice from Firestore
  Future<void> _deleteNotice(String noticeId, String databaseName) async {
    try {
      await FirebaseFirestore.instance
          .collection(databaseName) // Use the databaseName passed
          .doc(noticeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notice deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notice: $e')),
      );
    }
  }

  FloatingActionButton customFloatingActionButton(
      BuildContext context, String page) {
    return FloatingActionButton(
      onPressed: () {
        // Your action here
      },
      elevation: 11,
      backgroundColor: Colors.white,
      child: Container(
        height: 45.h,
        width: 45.h,
        decoration: BoxDecoration(
          border: Border.all(color: secondaryColor, width: 2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: primaryColor,
          size: 25.sp,
        ),
      ),
    );
  }
}
