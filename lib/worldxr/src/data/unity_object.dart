class UnityObject {
  String _id;
  String userID;
  double alt;
  double rotX;
  double rotY;
  double rotZ;
  Map<String, double> location;

  String get id => _id;

  UnityObject(this._id, this.userID, this.location, this.alt, this.rotX,
      this.rotY, this.rotZ);

  UnityObject.fromData(Map<String, dynamic> data)
      : _id = data['_id'],
        rotX = data['rotX'],
        rotY = data['rotY'],
        rotZ = data['rotZ'],
        userID = data['user'],
        alt = data['alt'],
        location = data['location'];

  Map<String, dynamic> toJson() {
    return {'_id': _id, 'user_id': userID, 'location': location};
  }
}
