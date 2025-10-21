import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../Provider/fcodelist_provider.dart';
import '../../../Utils/app_colors.dart';

//List<String> fcodeList = ["FYY76", "FYY97"];


class ManageOdsCodes extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ODS Codes",
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<FcodelistProvider>(context, listen: false).setSearchQuery(value);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search ODS Codes',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<FcodelistProvider>(
              builder: (context, provider, child) {
                if (provider.filteredFcodeList.isEmpty) {
                  provider.getFcodeList();
                }

                return ListView.builder(
                  itemCount: provider.filteredFcodeList.length,
                  itemBuilder: (context, index) {
                    var fcode = provider.filteredFcodeList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                      color: Colors.white10,
                      child: ListTile(
                        title: Text(fcode['fcode']!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, fcode['docId']!, fcode['fcode']!);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                provider.deleteFcode(fcode['docId']!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ODS Code'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter ODS Code'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String newFcode = controller.text.trim();
                if (newFcode.isNotEmpty) {
                  Provider.of<FcodelistProvider>(context, listen: false).addFcode(newFcode);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String docId, String existingFcode) {
    TextEditingController controller = TextEditingController(text: existingFcode);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ODS Code'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter ODS Code'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                String newFcode = controller.text.trim();
                if (newFcode.isNotEmpty) {
                  Provider.of<FcodelistProvider>(context, listen: false).updateFcode(docId, newFcode);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// Function to import the list to Firestore
// Future<void> importFcodes() async {
//   // Reference to the Firestore collection where you want to store each code as a separate document
//   CollectionReference fcodesCollection = FirebaseFirestore.instance.collection('fcodeList');
//
//   // Loop through the fcodeList and add each code as a separate document
//   for (String fcode in fcodeList) {
//     await fcodesCollection.add({
//       'fcode': fcode,  // Save each Fcode as a document with the field 'code'
//     });
//
//     print('Fcode $fcode added to Firestore.');
//   }
//
//   print('All Fcodes have been added to Firestore.');
// }
