import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../Utils/error_dialoge.dart';
//import 'notification_helper.dart';

class NoticeProvider with ChangeNotifier {

  Future addNewNotice({
    required String postText,
    required String postTitle,
    required String dateTime,
    required String databaseName,
    required String selectedAudience, // Added selectedAudience
    required BuildContext context,
  }) async {
    try {
      // Generate a new document reference (this gives you the dynamic noticeId)
      DocumentReference newNoticeRef = FirebaseFirestore.instance.collection(databaseName).doc();

      // Use the generated noticeId in the document and save data
      await newNoticeRef.set(
        {
          "postText": postText,
          "postTitle": postTitle,
          "dateTime": dateTime,
          "ownerUid": FirebaseAuth.instance.currentUser!.uid,
          "selectedAudience": selectedAudience, // Track selected audience
          "noticeId": newNoticeRef.id, // Store the noticeId
        },
      );

      // Send notification with the dynamic noticeId to the selected audience
      await sendNotificationToAudience(postTitle, postText, selectedAudience, newNoticeRef.id);
    } catch (e) {
      print("Error in addNewNotice sss: $e");  // Add this line
      return onError(context, "Having problem connecting to the server");
    }
  }


  Future<void> sendNotificationToAudience(
      String title,
      String body,
      String audience,
      String noticeId,
      ) async {
    QuerySnapshot usersSnapshot;
    String databaseName = 'notice';

    if (audience == "All Users") {
      usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    } else if (audience == "Contractor") {
      usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'contractor')
          .get();
      databaseName = 'contractorNotice';
    } else {
      // Additional specific audiences if required
      return;
    }

    for (var userDoc in usersSnapshot.docs) {
      var userData = userDoc.data() as Map<String, dynamic>?; // Cast to Map and handle null

      if (userData != null && userData.containsKey('token')) { // Check if token exists
        String deviceToken = userData['token'];
        //try {
          //await NotificationService.sendNotification(deviceToken, title, body, noticeId, databaseName);
        //} catch (e) {
          //print("Error sending notification to $deviceToken: $e");
        //}
      } else {
        print("Token field does not exist for user: ${userDoc.id}");
      }
    }
  }





  Future addPost({
    required String postText,
    required String imageUrl,
    required String dateTime,
    required String name,
    required BuildContext context,
  }) async {
    try {
      FirebaseFirestore.instance.collection(name + "Post").doc().set(
        {
          "postText": postText,
          "imageUrl": imageUrl,
          "dateTime": dateTime,
          "ownerUid": FirebaseAuth.instance.currentUser!.uid,
        },
      );
      notifyListeners();
    } catch (e) {
      return onError(context, "Having problem connecting to the server");
    }
  }

  Future updatePost({
    required String postText,
    required String imageUrl,
    required String name,
    required String id,
    required BuildContext context,
  }) async {
    try {
      FirebaseFirestore.instance.collection(name + "Post").doc(id).update(
        {
          "postText": postText,
          "imageUrl": imageUrl,
          "ownerUid": FirebaseAuth.instance.currentUser!.uid,
        },
      );
      notifyListeners();
    } catch (e) {
      return onError(context, "Having problem connecting to the server");
    }
  }

  Future updateNotice({
    required String postText,
    required String id,
    required String postTitle,
    required String databaseName,
    required BuildContext context,
  }) async {
    try {
      FirebaseFirestore.instance.collection(databaseName).doc(id).update(
        {
          "postText": postText,
          "postTitle": postTitle,
        },
      );
      notifyListeners();
    } catch (e) {
      return onError(context, "Having problem connecting to the server");
    }
  }

  Future addEvent({
    required String title,
    required String schedule,
    required String place,
    required String description,
    required String url,
    required String name,
    required BuildContext context,
  }) async {
    try {
      FirebaseFirestore.instance.collection(name + "Event").doc().set(
        {
          "title": title,
          "schedule": schedule,
          "place": place,
          "description": description,
          "url": url,
          "ownerUid": FirebaseAuth.instance.currentUser!.uid,
          "dateTime": DateTime.now(),
        },
      );
      notifyListeners();
    } catch (e) {
      return onError(context, "Having problem connecting to the server");
    }
  }

  Future updateEvent({
    required String title,
    required String schedule,
    required String id,
    required String place,
    required String description,
    required String url,
    required String name,
    required BuildContext context,
  }) async {
    try {
      FirebaseFirestore.instance.collection(name + "Event").doc(id).update(
        {
          "title": title,
          "schedule": schedule,
          "place": place,
          "description": description,
          "url": url,
        },
      );
      notifyListeners();
    } catch (e) {
      return onError(context, "Having problem connecting to the server");
    }
  }

  Future deleteNotice(String id) async {
    await FirebaseFirestore.instance.collection("notice").doc(id).delete();
    notifyListeners();
  }

  Future deleteEvent(String id, String postFrom) async {
    await FirebaseFirestore.instance.collection(postFrom).doc(id).delete();
    notifyListeners();
  }

  Future deletePost(String id, String postFrom) async {
    await FirebaseFirestore.instance.collection(postFrom).doc(id).delete();
    notifyListeners();
  }
}
