import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fusecash/worldxr/src/data/unity_object.dart';
import 'package:fusecash/worldxr/src/locator.dart';
import 'package:fusecash/worldxr/src/services/unity_service.dart';
import 'package:meta/meta.dart';

part 'unity_event.dart';
part 'unity_state.dart';

class UnityBloc extends Bloc<UnityEvent, UnityState> {
  UnityBloc() : super(UnityInitial());
  UnityService get _unityService => locator.get();

  @override
  Stream<UnityState> mapEventToState(
    UnityEvent event,
  ) async* {
    if (event is SaveUnityObject) {
      UnityObject unityObject = UnityObject(event.id, event.user, event.content,
          {'lat': event.lat, 'lng': event.lng});
      String fileName = await _unityService.addObjectToS3(unityObject);

      if (fileName != null) {
        await _unityService.addObjectToMongo(unityObject, fileName);
      }
    }
  }
}
