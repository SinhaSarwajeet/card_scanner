import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String phone;
  final String email;

  const ContactCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  Future<void> _addToContacts(BuildContext context) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        // Search for existing contacts by name, phone, or email
        List<Contact> existingContacts = await FlutterContacts.getContacts(
          withProperties: true,
        );

        bool contactExists = existingContacts.any((contact) {
          bool nameMatch = contact.name.first == name;
          bool phoneMatch = contact.phones.any((p) => p.number == phone);
          bool emailMatch = contact.emails.any((e) => e.address == email);
          return nameMatch || phoneMatch || emailMatch;
        });

        if (contactExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact already exists.'),
            ),
          );
        } else {
          final contact = Contact()
            ..name.first = name
            ..phones = [Phone(phone)]
            ..emails = [Email(email)];

          await contact.insert();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact added successfully!'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission to access contacts was denied.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking or adding contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding the contact.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.black,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.yellow.withOpacity(0.6),
                        Colors.pink.withOpacity(0.6),
                        Colors.blue.withOpacity(0.6)
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(.3),
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.grey),
                  title: Text(
                    phone,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.grey),
                  title: Text(
                    email,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToContacts(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add to Contacts'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Copy details to clipboard
                String details = 'Name: $name\nPhone: $phone\nEmail: $email';
                Clipboard.setData(ClipboardData(text: details)).then((_) {
                  // Show a snackbar to notify the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact details copied to clipboard!'),
                    ),
                  );
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 16, right: 16),
                child: Icon(
                  Icons.copy,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
