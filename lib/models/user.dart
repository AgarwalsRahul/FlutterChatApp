

class User {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  User({
    this.id,
    this.name,
    this.imageUrl,
    this.email,
  });


   Map<String,dynamic> toMap(){
    return {
      'name':name,
      'email':email,
      'image':imageUrl,
      'lastSeen':DateTime.now().toUtc(),
    };
  }
}
