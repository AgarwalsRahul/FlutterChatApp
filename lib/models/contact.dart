import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String image;
  final String email;
  final String name;
  final Timestamp lastSeen;
  Contact({
    this.id,
    this.email,
    this.image,
    this.lastSeen,
    this.name,
  });

  factory Contact.fromfirestore(DocumentSnapshot _snapshot) {
    var data = _snapshot.data;
    return Contact(
      email: data['email'],
      id: _snapshot.documentID,
      image: data['image'],
      lastSeen: data['lastSeen'],
      name: data['name'],
    );
  }
}
