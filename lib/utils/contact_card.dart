import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
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
                    child: const Icon(Icons.copy, color: Colors.blue, size: 18,),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(phone),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: Text(email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
