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

/*  Flutter sends the object content to the backend in this schema.
    {
        author: string,
        content: string,
        location: {
            latitude: number,
            longitude: number
        }
    }
 */

class SaveUnityObject extends UnityEvent {
  final String id;
  final String user;
  final String content;
  final double lat;
  final double lng;

  SaveUnityObject(this.id, this.user, this.content, this.lat, this.lng);
}

//unity sends the user's location to the flutter to get the objects near the user
class LocationFromUnity extends UnityEvent {
  final double lat;
  final double lng;

  LocationFromUnity(this.lat, this.lng);
}

// The backend should have an API that retrieves the user location and
// search for objects near the location in the database.
class RetrieveObject extends UnityEvent {
  final String id;

  RetrieveObject(this.id);
}
