import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllowedDomainsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of maps to store domain and docId together
  List<Map<String, String>> _allowedDomainsList = [];
  List<Map<String, String>> get allowedDomainsList => _allowedDomainsList;

  // Fetch allowed domains list from Firestore
  Future<void> getAllowedDomainsList() async {
    try {
      // Fetch data from Firestore collection
      QuerySnapshot snapshot = await _firestore.collection('allowedDomains').get();

      // Map through the documents and extract domain fields with docId
      _allowedDomainsList = snapshot.docs
          .map((doc) => {
        'domain': doc['domain'] as String,
        'docId': doc.id, // Store the document ID
      })
          .toList();

      // Notify listeners about the data change
      notifyListeners();
    } catch (e) {
      print("Error fetching allowedDomainsList: $e");
    }
  }

  // Add new domain to Firestore
  Future<void> addDomain(String domain) async {
    try {
      // Add new domain to Firestore
      var docRef = await _firestore.collection('allowedDomains').add({'domain': domain});

      // Add the new domain with docId to the local list
      _allowedDomainsList.add({'domain': domain, 'docId': docRef.id});

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print("Error adding domain: $e");
    }
  }

  // Update domain in Firestore (based on domain ID)
  Future<void> updateDomain(String docId, String newDomain) async {
    try {
      // Update domain in Firestore
      await _firestore.collection('allowedDomains').doc(docId).update({'domain': newDomain});

      // Update the domain locally by finding the corresponding docId
      final index = _allowedDomainsList.indexWhere((domainMap) => domainMap['docId'] == docId);
      if (index != -1) {
        _allowedDomainsList[index]['domain'] = newDomain; // Update the domain value
        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      print("Error updating domain: $e");
    }
  }

  // Delete domain from Firestore (based on domain ID)
  Future<void> deleteDomain(String docId) async {
    try {
      // Delete the domain from Firestore
      await _firestore.collection('allowedDomains').doc(docId).delete();

      // Remove the domain from the local list
      _allowedDomainsList.removeWhere((domainMap) => domainMap['docId'] == docId);

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print("Error deleting domain: $e");
    }
  }
}
