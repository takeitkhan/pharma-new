import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../Provider/profile_provider.dart';
import '../../../Provider/search_provider.dart';
import '../../Chat/Chat.dart';
import 'EditProfile.dart';
import 'ViewProfile.dart';

enum SampleItem { admin, driver, user }

class UserList extends StatefulWidget {
  final bool? isAdminPanel;

  UserList({Key? key, this.isAdminPanel}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<ProfileProvider>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        return Consumer<SearchProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                // Safely get each user's document data
                var userDoc = data?.docs[index].data() as Map<String, dynamic>?;

                String name = userDoc?["name"] ?? "No Name"; // Fallback if name is null
                if (name.toLowerCase().contains(provider.userSearchText.toLowerCase())) {
                  return _user(context, data, index, name, pro);
                }
                return const SizedBox();
              },
              itemCount: data?.size ?? 0,
            );
          },
        );
      },
    );
  }

  Column _user(BuildContext context, QuerySnapshot<Object?>? data, int index, String name, ProfileProvider pro) {
    var userDoc = data?.docs[index].data() as Map<String, dynamic>?;

    String avatarUrl = userDoc?["url"] ?? "assets/profile.jpg"; // Default to local asset if null

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProfile(id: data!.docs[index].id),
              ),
            );
          },
          child: Container(
            height: 30,
            width: 350,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 21,
                  backgroundImage: avatarUrl.startsWith("http")
                      ? NetworkImage(avatarUrl)
                      : AssetImage(avatarUrl) as ImageProvider<Object>,
                ),
                SizedBox(width: 12.w),
                Text(
                  name.length > 13 ? '${name.substring(0, 13)}...' : name,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    return changeRole(userDoc?["role"] ?? "User", index);
                  },
                ),
                SizedBox(width: 10.w),
                if (pro.role == "admin" || pro.role == "contractor")
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.black),
                    onSelected: (String value) {
                      if (data == null) return;

                      if (value == "delete") {
                        _deleteUser(data.docs[index].id);
                      } else if (value == "send_message") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chat(
                              name: userDoc?["name"] ?? "No Name",
                              url: userDoc?["url"] ?? "",
                              token: userDoc?["token"] ?? "",
                              uid: data.docs[index].id,
                            ),
                          ),
                        );
                      } else {
                        _changeUserRole(data.docs[index].id, value);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        if (userDoc?["role"] != "admin")
                          const PopupMenuItem<String>(
                            value: "admin",
                            child: Text("Change to Admin"),
                          ),
                        if (userDoc?["role"] != "contractor")
                          const PopupMenuItem<String>(
                            value: "contractor",
                            child: Text("Change to Contractor"),
                          ),
                        const PopupMenuItem<String>(
                          value: "send_message",
                          child: Text("Send Message"),
                        ),
                        const PopupMenuItem<String>(
                          value: "delete",
                          child: Text("Delete User"),
                        ),
                      ];
                    },
                  )
                else
                  SizedBox(width: 40.w),
              ],
            ),
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  void _changeUserRole(String userId, String newRole) {
    FirebaseFirestore.instance.collection("users").doc(userId).update({
      'role': newRole,
    }).then((_) {
      print("User role updated to $newRole");
    }).catchError((error) {
      print("Failed to update role: $error");
    });
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection("users").doc(userId).delete().then((_) {
      print("User deleted successfully");
    }).catchError((error) {
      print("Failed to delete user: $error");
    });
  }

  Widget changeRole(String role, int index) {
    return Center(
      child: Text(
        role == "admin" ? "Admin" : role == "contractor" ? "Contractor" : "User",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
