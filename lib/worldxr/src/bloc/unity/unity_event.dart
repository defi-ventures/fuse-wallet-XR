part of 'unity_bloc.dart';

@immutable
abstract class UnityEvent {}

//  Unity sends the binary content of the object to Flutter

class ObjectFromUnity extends UnityEvent {
  final String content;
  final double lat;
  final double lng;
  final double alt;

  ObjectFromUnity(this.content, this.lat, this.lng, this.alt);
}

class LoadObjectsForLocation extends UnityEvent {
  final Map<String, double> location;

  LoadObjectsForLocation(this.location);
}

class SaveUnityObject extends UnityEvent {
  final String id;
  final String user;
  final double lat;
  final double lng;
  final double alt;
  final double rotX;
  final double rotY;
  final double rotZ;

  SaveUnityObject(this.id, this.user, this.lat, this.lng, this.alt, this.rotX,
      this.rotY, this.rotZ);
}

//unity sends the user's location to the flutter to get the objects near the user
class LocationFromUnity extends UnityEvent {
  final double lat;
  final double lng;
  final double alt;

  LocationFromUnity(this.lat, this.lng, this.alt);
}

// The backend should have an API that retrieves the user location and
// search for objects near the location in the database.
class RetrieveObject extends UnityEvent {
  final String id;

  RetrieveObject(this.id);
}
