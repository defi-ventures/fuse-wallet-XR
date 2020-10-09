import 'dart:async';
import 'package:fusecash/worldxr/src/data/unity_object.dart';
import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/services/unity_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'unity_event.dart';
part 'unity_state.dart';

class UnityBloc extends Bloc<UnityEvent, UnityState> {
  UnityBloc() : super(UnityState.initial());
  UnityService get _unityService => locator.get();

  @override
  void onTransition(Transition<UnityEvent, UnityState> transition) {
    super.onTransition(transition);
    print(transition.nextState);
  }

  @override
  Stream<UnityState> mapEventToState(
    UnityEvent event,
  ) async* {
    if (event is LocationFromUnity) {
      Map<String, double> location =
          Map.from({"lat": event.lat, "lng": event.lng});
      yield UnityState.locationRetrieved(location);
    }

    if (event is LoadObjectsForLocation) {
      _unityService.getObjectsForLocation(
          event.location['lat'].toStringAsFixed(2),
          event.location['lng'].toStringAsFixed(2));
    }

    if (event is SaveUnityObject) {
      UnityObject unityObject = UnityObject(
        event.id,
        event.user,
        {'lat': event.lat, 'lng': event.lng},
        event.alt,
        event.rotX,
        event.rotY,
        event.rotZ,
      );

      await _unityService.addObjectToMongo(unityObject);
    }
  }
}
