import 'package:chat_application/models/Conversation.dart';
import 'package:chat_application/models/contact.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static DBService instance = DBService();
  Firestore _db = Firestore.instance;
  String _userCollections = 'Users';
  String _conversationCollections = 'Conversations';

  Future<void> createUserInDatabase(User user) async {
    try {
      return await _db
          .collection(_userCollections)
          .document(user.id)
          .setData(user.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<Contact> getUserData(String uid) {
    var _ref = _db.collection(_userCollections).document(uid);
    return _ref
        .get()
        .asStream()
        .map((snapshot) => Contact.fromfirestore(snapshot));
  }

  Stream<List<Conversation>> getUserConversations(String uid) {
    var _ref = _db
        .collection(_userCollections)
        .document(uid)
        .collection(_conversationCollections);
    return _ref.snapshots().map((_snapshots) {
      return _snapshots.documents.map((doc) {
        return Conversation.fromfirestore(doc);
      }).toList();
    });
  }

  Future<void> sendMessage(String conversationID, Message message) {
    var _ref =
        _db.collection(_conversationCollections).document(conversationID);
    var _messageType = message.type == MessageType.Text ? 'text' : 'image';
    return _ref.updateData({
      'messages': FieldValue.arrayUnion([
        {
          'message': message.content,
          'senderID': message.senderID,
          'type': _messageType,
          'timestamp': message.timestamp,
        }
      ]),
    });
  }

  Stream<Conversations> getConversations(String conversationID) {
    var _ref =
        _db.collection(_conversationCollections).document(conversationID);
    return _ref.snapshots().map((snapshot) {
      return Conversations.fromfirestore(snapshot);
    });
  }

  Future<void> updateLastSeen(String uid) {
    var _ref = _db.collection(_userCollections).document(uid);
    return _ref.updateData({
      'lastSeen': Timestamp.now(),
    });
  }

  Stream<List<Contact>> getUsers(String _searchText) {
    var _ref = _db
        .collection(_userCollections)
        .where("name", isGreaterThanOrEqualTo: _searchText)
        .where('name', isLessThan: _searchText + 'z');
    return _ref.getDocuments().asStream().map((snapshot) {
      return snapshot.documents.map((_doc) {
        return Contact.fromfirestore(_doc);
      }).toList();
    });
  }

  Future<void> createOrGetConversations(String _currentID, String _recipientID,
      Future<void> onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationCollections);
    var _userConversationRef = _db
        .collection(_userCollections)
        .document(_currentID)
        .collection(_conversationCollections);
    try {
      var conversation =
          await _userConversationRef.document(_recipientID).get();
      if (conversation.data != null) {
        return onSuccess(conversation.data['conversationID']);
      } else {
        var _conversationref = _ref.document();
        await _conversationref.setData({
          'messages': [],
          'ownerID': _currentID,
          'members': [_currentID, _recipientID],
        });
        return onSuccess(_conversationref.documentID);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
