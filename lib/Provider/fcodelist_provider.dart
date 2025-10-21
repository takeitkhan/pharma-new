import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FcodelistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of maps to store fcode and docId together
  List<Map<String, String>> _fcodeList = []; // Example list structure
  List<Map<String, String>> _filteredFcodeList = [];

  List<Map<String, String>> get fcodeList => _filteredFcodeList.isEmpty ? _fcodeList : _filteredFcodeList;
  List<Map<String, String>> get filteredFcodeList => _filteredFcodeList;


  // Fetch fcode list from Firestore
  Future<void> getFcodeList() async {
    try {
      // Fetch data from Firestore collection
      QuerySnapshot snapshot = await _firestore.collection('fcodeList').get();

      // Map through the documents and extract fcode fields with docId
      _fcodeList = snapshot.docs
          .map((doc) => {
        'fcode': doc['fcode'] as String,
        'docId': doc.id, // Store the document ID
      })
          .toList();

      _filteredFcodeList = _fcodeList;

      // Notify listeners about the data change
      notifyListeners();
    } catch (e) {
      print("Error fetching fcodeList: $e");
    }
  }

  // Add new fcode to Firestore
  Future<void> addFcode(String fcode) async {
    try {
      // Add new fcode to Firestore
      var docRef = await _firestore.collection('fcodeList').add({'fcode': fcode});

      // Add the new fcode with docId to the local list
      _fcodeList.add({'fcode': fcode, 'docId': docRef.id});

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print("Error adding fcode: $e");
    }
  }

  // Update fcode in Firestore (based on fcode ID)
  Future<void> updateFcode(String docId, String newFcode) async {
    try {
      // Update fcode in Firestore
      await _firestore.collection('fcodeList').doc(docId).update({'fcode': newFcode});

      // Update the fcode locally by finding the corresponding docId
      final index = _fcodeList.indexWhere((fcodeMap) => fcodeMap['docId'] == docId);
      if (index != -1) {
        _fcodeList[index]['fcode'] = newFcode; // Update the fcode value
        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      print("Error updating fcode: $e");
    }
  }

  // Delete fcode from Firestore (based on fcode ID)
  Future<void> deleteFcode(String docId) async {
    try {
      // Delete the fcode from Firestore
      await _firestore.collection('fcodeList').doc(docId).delete();

      // Remove the fcode from the local list
      _fcodeList.removeWhere((fcodeMap) => fcodeMap['docId'] == docId);

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print("Error deleting fcode: $e");
    }
  }

  // Set the search query and filter the list
  void setSearchQuery(String query) {
    if (query.isEmpty) {
      _filteredFcodeList = _fcodeList;
    } else {
      _filteredFcodeList = _fcodeList.where((fcode) {
        return fcode['fcode']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}