part of 'unity_bloc.dart';

enum UnityStatus { initial, locationRetrieved, objectsRetrieved }

class UnityState extends Equatable {
  const UnityState._(
      {this.userLocation,
      this.locationRequestedObjects,
      this.unityStatus = UnityStatus.initial});

  UnityState.initial() : this._();

  UnityState.locationRetrieved(userLocation)
      : this._(
            unityStatus: UnityStatus.locationRetrieved,
            userLocation: userLocation);
  UnityState.objectsRetrieved(userLocation, locationRequestedObjects)
      : this._(
            unityStatus: UnityStatus.locationRetrieved,
            userLocation: userLocation,
            locationRequestedObjects: locationRequestedObjects);

  final UnityStatus unityStatus;
  final Map<String, double> userLocation;
  final List<UnityObject> locationRequestedObjects;

  @override
  List<Object> get props =>
      [unityStatus, userLocation, locationRequestedObjects];
}
