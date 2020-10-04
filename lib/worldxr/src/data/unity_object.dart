class UnityObject {
  String _id;
  String userID;
  String contentAddress;
  String content;
  Map location;

  String get id => _id;

  UnityObject(this._id, this.userID, this.content, this.location);

  UnityObject.fromData(Map<String, dynamic> data) {
    _id = data['_id'];
    userID = data['user'];
    content = data['content'];
    location = data['location'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      "user_id": userID,
      'content': content,
      'content_address': contentAddress,
      'location': location
    };
  }
}
