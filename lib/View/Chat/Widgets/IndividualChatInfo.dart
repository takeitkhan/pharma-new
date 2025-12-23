import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Provider/chat_provider.dart';
import '../../../Provider/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Chat.dart';

class IndividualChatInfo extends StatefulWidget {
  final String uid;
  final String lastMs;

  const IndividualChatInfo({
    Key? key,
    required this.uid,
    required this.lastMs,
  }) : super(key: key);

  @override
  State<IndividualChatInfo> createState() => _IndividualChatInfoState();
}

class _IndividualChatInfoState extends State<IndividualChatInfo> {
  bool isLoading = true;
  late DocumentSnapshot data;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    data = await Provider.of<ProfileProvider>(context, listen: false)
        .getProfileInfoByUID(widget.uid);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      child: isLoading ? _buildShimmer() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Chat(
              name: data["name"],
              url: data["url"],
              uid: data.id,
              token: data["token"],
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 26.sp,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: data["url"] != ""
                ? NetworkImage(data["url"])
                : const AssetImage("assets/profile.jpg") as ImageProvider,
          ),

          SizedBox(width: 14.w),

          // Name + Last Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"],
                  style: GoogleFonts.lato(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ChatProvider.decrypt(widget.lastMs),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.sp,
          backgroundColor: Colors.grey.shade300,
        ),
        SizedBox(width: 14.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 140.w, height: 16.h, color: Colors.grey.shade300),
            SizedBox(height: 6.h),
            Container(width: 200.w, height: 14.h, color: Colors.grey.shade300),
          ],
        ),
      ],
    );
  }
}
