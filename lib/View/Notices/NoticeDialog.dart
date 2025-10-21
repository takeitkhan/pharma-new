import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoticeDialog extends StatefulWidget {
  final String noticeId;
  final String databaseName;

  const NoticeDialog({Key? key, required this.noticeId, required this.databaseName})
      : super(key: key);

  @override
  _NoticeDialogState createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<NoticeDialog> {
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
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(widget.databaseName)
          .doc(widget.noticeId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          notice = doc; // Store the notice data
          payload = doc.data() as Map<String, dynamic>; // Convert data to Map
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notice: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Notice Details",
        style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      content: notice == null // Show loading or notice details
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _buildNoticeCard(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildNoticeCard() {
    return Card(
      color: Colors.grey[200], // Light background color for card
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.title, "Title", payload['postTitle'] ?? "N/A"),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.lock_clock_rounded,
              "Created",
              payload['dateTime'] != null
                  ? DateFormat('dd-MM-yyyy').format(DateTime.parse(payload['dateTime']))
                  : "N/A", // Correct date formatting and fallback
            ),
            SizedBox(height: 12),
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
        Icon(icon, color: Colors.grey, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                content,
                style: GoogleFonts.lato(
                  fontSize: 14,
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
