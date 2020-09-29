using ARLocation;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using Newtonsoft.Json.Linq;

[RequireComponent(typeof(ARRaycastManager))]
public class TapToPlaceObjects : MonoBehaviour
{
    public FlutterMessenger _flutterMessenger;
    public GameObject GameObjectToInstantiate;
    public GameObject RemoveBtn;
    public GameObject GotoBtn;
    public GameObject CustomTextInput;
    public GameObject CustomTextTemplate;
    public Camera ArCamera;

    private bool _isText = false;
    public GameObject _selectedObject;
    public GameObject _couldBeDeleted;
    public bool _isgameobjectselected = false;
    private readonly List<GameObject> _arObjects = new List<GameObject>();

    private ARRaycastManager _arRaycastManager;

    static List<ARRaycastHit> hits = new List<ARRaycastHit>();

    private void Awake()
    {
        _flutterMessenger = GetComponent<FlutterMessenger>();
        _arRaycastManager = GetComponent<ARRaycastManager>();
    }

    bool TryGetTouchPosition(out Vector2 touchPosition)
    {
        if (Input.touchCount == 1)
        {
            touchPosition = Input.GetTouch(0).position;
            return true;
        }

        touchPosition = default;
        return false;
    }

    bool TryGetTappedObject()
    {
        GameObject tappedObject = null;
        if (Input.GetTouch(0).phase != TouchPhase.Began)
        {
            return false;
        }

        Ray raycast = ArCamera.ScreenPointToRay(Input.GetTouch(0).position);
        RaycastHit raycastHit;

        if (Physics.Raycast(raycast, out raycastHit))
        {
            tappedObject = raycastHit.transform.gameObject;
            if (tappedObject != null)
            {
                foreach (var arObject in _arObjects)
                {
                    if (GameObject.ReferenceEquals(arObject, tappedObject))
                    {
                        _selectedObject = tappedObject.gameObject;
                        _couldBeDeleted = tappedObject.gameObject;
                        RemoveBtn.SetActive(true);
                        _isgameobjectselected = true;
                        return true;
                    }
                    else
                    {
                        _selectedObject = null;
                        _isgameobjectselected = false;
                    }
                }
            }
        }

        if (GameObject.ReferenceEquals(RemoveBtn, tappedObject))
        {
            GotoBtn.GetComponentInChildren<Text>().text = "Remove button";
            //RemoveSelectedObject();
            return true;
        }

        //RemoveBtn.SetActive(false);

        return false;
    }

    Location CalcLocation(LocationInfo userLoc, double distance, double bearing)
    {
        var R = 6371009d;    //Earth radius in meters

        // Convert user lat/lng from degrees to radians
        var userLat = userLoc.latitude * (Math.PI / 180);
        var userLng = userLoc.longitude * (Math.PI / 180);
        bearing = bearing * (Math.PI / 180);
        distance /= R;

        var objLat = Math.Asin(Math.Sin(userLat) * Math.Cos(distance) + Math.Cos(userLat) * Math.Sin(distance) * Math.Cos(bearing));
        var objLng = userLng + Math.Atan2(Math.Sin(bearing) * Math.Sin(distance) * Math.Cos(userLat), Math.Cos(distance) - Math.Sin(userLat) * Math.Sin(objLat));

        var objLoc = new Location()
        {
            // Need to convert radians from degrees
            Latitude = objLat * (180 / Math.PI),
            Longitude = objLng * (180 / Math.PI),
            Altitude = userLoc.altitude,
            AltitudeMode = AltitudeMode.GroundRelative
        };

        return objLoc;
    }

    // Calculate the distance in M
    private double CalcDistance(double lat1, double lon1, double lat2, double lon2)
    {
        if ((lat1 == lat2) && (lon1 == lon2))
        {
            return 0;
        }
        else
        {
            double theta = lon1 - lon2;
            double dist = Math.Sin(deg2rad(lat1)) * Math.Sin(deg2rad(lat2)) + Math.Cos(deg2rad(lat1)) * Math.Cos(deg2rad(lat2)) * Math.Cos(deg2rad(theta));
            dist = Math.Acos(dist);
            dist = rad2deg(dist);
            dist = dist * 60 * 1.1515;
            dist = dist * 1.609344 * 1000;

            return (dist);
        }
    }

    private double deg2rad(double deg)
    {
        return (deg * Math.PI / 180.0);
    }

    private double rad2deg(double rad)
    {
        return (rad / Math.PI * 180.0);
    }

    void SaveObject(GameObject gameObject, Location location)
    {
        print("save object flutter messenger");
        FlutterMessenger.SaveObject(gameObject, location);
    }

    void PlaceObject(GameObject gameObject)
    {
        Pose objPosition = new Pose()
        {
            position = gameObject.transform.position,
            rotation = gameObject.transform.rotation
        };

        var dist = Vector2.Distance(Camera.main.transform.position, objPosition.position);
        var bearing = Vector2.Angle(Camera.main.transform.position, objPosition.position) + Input.compass.trueHeading;

        var objLoc = CalcLocation(Input.location.lastData, dist, bearing);

        var opts = new PlaceAtLocation.PlaceAtOptions()
        {
            HideObjectUntilItIsPlaced = true,
            MaxNumberOfLocationUpdates = 2,
            MovementSmoothing = 0.1f,
            UseMovingAverage = false
        };

        print("saving object");
        SaveObject(gameObject, objLoc);

      // PlaceAtLocation.CreatePlacedInstance(gameObject, objLoc, opts);
    }

    void RequestObjects()
    {
        foreach(var obj in FlutterMessenger.NearbyObjects)
        {
            if(obj.content == null && obj.isRequested == false
                && CalcDistance(obj.location.Latitude, obj.location.Longitude, Input.location.lastData.latitude, Input.location.lastData.longitude) < 100)
            {
                print("requesting objects in loop");
                FlutterMessenger.RequestObjectDetails(obj.id);
            }
        }
    }
    public void deleteobject()
    {
        ///if (_selectedObject)
        //{
            Destroy(_couldBeDeleted);
           // _selectedObject = null;
            RemoveBtn.SetActive(false);
       // }
    }
    public void CheckForObjectChange()
    {
        if (FlutterMessenger.SelectedGameObject != null)
        {
            GameObjectToInstantiate = FlutterMessenger.SelectedGameObject;
        }

    }
    void Update()
    {
        CheckForObjectChange();
        try{
 if (!TryGetTouchPosition(out Vector2 touchPosition))
            return;

        if (!TryGetTappedObject())//Will work if we have not selected any ar object
            {

            if (_arRaycastManager.Raycast(touchPosition, hits, TrackableType.PlaneWithinPolygon))
            {
                var hitPose = hits[0].pose;

                RequestObjects();
                    

                switch (Input.GetTouch(0).phase)
                {
                  
                    case TouchPhase.Began:
                        if(_isText) 
                        {
                                _selectedObject = Instantiate(CustomTextTemplate, hitPose.position, hitPose.rotation);
                            } 
                        else
                        {
                                if (!_isgameobjectselected)
                                {
                                    _selectedObject = Instantiate(GameObjectToInstantiate, hitPose.position, hitPose.rotation);
                                    print("placing object");
                                    PlaceObject(_selectedObject);
                                }
                                
                        }

                        _isText = false;
                        _arObjects.Add(_selectedObject);
                            

                        RemoveBtn.SetActive(true);
                    

                        break;

                    case TouchPhase.Moved:
                        _selectedObject.transform.position = hitPose.position;
                        break;

                    case TouchPhase.Ended:
                        break;

                    default:
                        break;
                }
            }
        }
        }
        catch (Exception e)
        {
    
        print(e.ToString());
        var message = new UnityMessage()
        {
            name = "UNITY_ERROR",
            data = JObject.FromObject(new {message = e.ToString() }),
           
        };

            FlutterMessenger.SendMessage(message);
        }

       
    }

    // Start is called before the first frame update
    IEnumerator Start()
    {
        _selectedObject = null;
        _couldBeDeleted = null;
        RemoveBtn.SetActive(false);
        CustomTextInput.SetActive(false);

        // First, check if user has location service enabled
        if (!Input.location.isEnabledByUser)
            yield break;

        // Start service before querying location
        Input.location.Start();

        // Wait until service initializes
        int maxWait = 20;
        while (Input.location.status == LocationServiceStatus.Initializing && maxWait > 0)
        {
            yield return new WaitForSeconds(1);
            maxWait--;
        }

        // Service didn't initialize in 20 seconds
        if (maxWait < 1)
        {
            print("Timed out");
            yield break;
        }

        if (Input.location.status == LocationServiceStatus.Failed)
        {
            // Connection has failed
            print("Unable to determine device location");
            yield break;
        }
        else
        {
            // Access granted and location value could be retrieved
            var userLoc = new Location()
            {
                Latitude = Input.location.lastData.latitude,
                Longitude = Input.location.lastData.longitude,
                Altitude = Input.location.lastData.altitude,
                AltitudeMode = AltitudeMode.GroundRelative
            };

            FlutterMessenger.SendUserLocation(userLoc);
        }
        
    }

    public void RemoveSelectedObject()
    {
        if (_selectedObject)
        {
            Destroy(_selectedObject);
            _selectedObject = null;
            //RemoveBtn.SetActive(false);
        }
    }

    public void AddCustomText()
    {
        CustomTextInput.SetActive(true);
    }

    public void OnChangeCustomText()
    {
        InputField inputField = CustomTextInput.GetComponent<InputField>();
        string value = inputField.text;
        if(!string.IsNullOrEmpty(value))
        {
            CustomTextTemplate.GetComponent<Text>().text = value;
            _isText = true;
        }
        CustomTextInput.SetActive(false);
    }

    public void ReceiveMessage(object msg_str)
    {
        try
        {
            print("Unity recieved message in TapToPlace");
            _flutterMessenger.StartCoroutine(FlutterMessenger.ReceiveMessage(msg_str));
        }
        catch(Exception e)
        {
            print(e);
        }
      
    }
}
