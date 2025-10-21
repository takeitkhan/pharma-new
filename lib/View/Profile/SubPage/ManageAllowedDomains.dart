import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/allowed_domains_provider.dart'; // Adjust this import path based on your provider location
import '../../../Utils/app_colors.dart'; // Adjust this import if needed

class ManageAllowedDomains extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Allowed Domains",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Plus Button
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Open Add Domain Dialog
              _showAddDomainDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<AllowedDomainsProvider>(
        builder: (context, provider, child) {
          // Ensure the allowed domains are loaded
          if (provider.allowedDomainsList.isEmpty) {
            // If the list is empty, fetch the allowed domains
            provider.getAllowedDomainsList();
          }

          return Column(
            children: [
              // List of Allowed Domains
              Expanded(
                child: ListView.builder(
                  itemCount: provider.allowedDomainsList.length,
                  itemBuilder: (context, index) {
                    var domain = provider.allowedDomainsList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      color: Colors.grey[200], // Adjust the color if needed
                      child: ListTile(
                        title: Text(domain['domain']!), // Display domain
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Button
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDomainDialog(context, domain['docId']!, domain['domain']!);
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                provider.deleteDomain(domain['docId']!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show Add Domain Dialog
  void _showAddDomainDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Allowed Domain'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter Domain'),
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
                String newDomain = controller.text.trim();
                if (_isValidDomain(newDomain)) {
                  // Add new domain to Firestore
                  Provider.of<AllowedDomainsProvider>(context, listen: false).addDomain(newDomain);
                  Navigator.of(context).pop();
                } else {
                  _showValidationError(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show Edit Domain Dialog
  void _showEditDomainDialog(BuildContext context, String docId, String existingDomain) {
    TextEditingController controller = TextEditingController(text: existingDomain);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Allowed Domain'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter Domain'),
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
                String newDomain = controller.text.trim();
                if (_isValidDomain(newDomain)) {
                  // Update domain in Firestore
                  Provider.of<AllowedDomainsProvider>(context, listen: false)
                      .updateDomain(docId, newDomain);
                  Navigator.of(context).pop();
                } else {
                  _showValidationError(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Check if the domain is valid
  bool _isValidDomain(String domain) {
    // Domain must start with "@" and contain at least one "."
    //return domain.startsWith('@') && domain.contains('.');
    return domain.contains('.');
  }

  // Show Validation Error Dialog
  void _showValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Domain'),
          content: Text('Domain must contain at least one dot (".").'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
