import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  FirebaseStorage _storage;
  StorageReference _baseReference;
  static CloudStorageService instance = CloudStorageService();
  String _profileImages = 'profile_images';
  String _images = 'images';
  String _messages = 'messages';
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseReference = _storage.ref();
  }
  Future<StorageTaskSnapshot> uploadImage(File _image, String _uid) async {
    try {
      return await _baseReference
          .child(_profileImages)
          .child(_uid)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e.toString());
    }

  }

  Future<StorageTaskSnapshot> uploadMediaImage(File image,String uid) {
    var timestamp = DateTime.now();
    var fileName = basename(image.path);
    fileName += '${timestamp.toString()}';
    try{
    return _baseReference.child(_messages).child(_images).child(uid).child(fileName).putFile(image).onComplete;
    } catch(e){
      print(e.toString());
    }
  }
}
