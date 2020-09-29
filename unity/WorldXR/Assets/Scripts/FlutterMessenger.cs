using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using ARLocation;
using Newtonsoft.Json.Linq;
using UnityEngine;
using UnityEngine.UI;
using System;
using Newtonsoft.Json;

public class FlutterMessenger : MonoBehaviour
{
    static UnityMessageManager _messenger;
    private const string Login = "LOGIN";
    private const string NewObject = "NEW_OBJECT";
    private const string NewObjectResult = "NEW_OBJECT_RESULT";
    private const string CurrentLocation = "CURRENT_LOCATION";
    private const string NearbyObjectList = "NEARBY_OBJECT_LIST";
    private const string RequestObject = "REQUEST_OBJECT";
    private const string ObjectContent = "OBJECT_CONTENT";
    private const string ObjectSelected = "OBJECT_SELECTED";

    public static List<ARObject> NearbyObjects = new List<ARObject>();
    public static UserInfo UserInfo = null;
    public static GameObject SelectedGameObject = null;

    void Awake() { }

    void Start() { 
        _messenger = new UnityMessageManager();
    }

    public static void SendMessage(UnityMessage message)
    {
        print("sending message to Flutter, FlutterMessenger");
        string jsondata = JsonConvert.SerializeObject(message,  Formatting.Indented, new JsonSerializerSettings() {
        PreserveReferencesHandling = PreserveReferencesHandling.Objects,
        ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore });
        _messenger.SendMessageToFlutter(jsondata);
    }

    public static void SaveObject(GameObject gameObject, Location location)
    {
        var message = new UnityMessage()
        {
            name = NewObject,
            data = JObject.FromObject(new ARObject()
            {
                id = null,
                content = gameObject,
                location = ARObjectLocation.FromLocationObj(location)
            }),
            callBack = s => ReceiveMessage(s)
        };

        print("sending message to flutter, save object");

        SendMessage(message);
    }

    public static void SendUserLocation(Location location)
    {
        var message = new UnityMessage()
        {
            name = CurrentLocation,
            data = JObject.FromObject(ARObjectLocation.FromLocationObj(location)),
            callBack = s => ReceiveMessage(s)
        };

        SendMessage(message);
    }

    public static void RequestObjectDetails(string objectId)
    {
        print("requesting object details, FlutterMessenger");
        var message = new UnityMessage()
        {
            name = RequestObject,
            data = JObject.FromObject(objectId),
            callBack = s => ReceiveMessage(s)
        };

        SendMessage(message);

        NearbyObjects = NearbyObjects.Where(obj => string.Compare(obj.id, objectId) == 0)
            .Select(obj => { obj.isRequested = true; return obj; })
            .ToList();
    }

    public static IEnumerator ReceiveMessage(object msg_str)
    {
        try{
        UnityMessage message = JsonConvert.DeserializeObject<UnityMessage>((string)msg_str);
        print("Unity serialized message: "+ message.name);
        switch (message.name)
        {
            case ObjectSelected:
                var objectType = message.data.Value<string>("type");
                switch(objectType)
                {
                    case "box":
                        SelectedGameObject = Resources.Load<GameObject>("Prefabs/Cube");
                        print(SelectedGameObject);
                        print("selected box");
                        break;

                    case "zombie":
                        SelectedGameObject = Resources.Load<GameObject>("Prefabs/Walking Zombie");
                        print("selected zombie");
                        break;

                    case "text":
                        SelectedGameObject = GameObject.Find("ARCanvas/TextTemplate");
                        SelectedGameObject.GetComponent<Text>().text = message.data.Value<string>("content");
                         print("selected text");
                        break;

                    case "image":
                        SelectedGameObject = GameObject.Find("ARCanvas/ImageTemplate");

                        using (var www = new WWW(message.data.Value<string>("content")))
                        {
                            //yield return www;

                            SelectedGameObject.GetComponent<RawImage>().texture = www.texture;
                        }
                        break;

                    default:
                        print("object not found");
                        break;
                }
                break;

            case Login:
                UserInfo = message.data.ToObject<UserInfo>();
                break;

            case NewObjectResult:
                break;

            case NearbyObjectList:
                NearbyObjects = message.data.ToObject<List<ARObject>>();
                break;

            case ObjectContent:
                var id = message.data.Value<string>("id");
                NearbyObjects = NearbyObjects.Where(obj => string.Compare(obj.id, id) == 0)
                    .Select(obj => { obj.content = message.data.Value<GameObject>("content"); return obj; })
                    .ToList();
                break;

            default:
                break;
        }

        }
        catch(Exception e){
     
            print(e);
        }
        yield return null;
        
    }
}

public class ARObjectLocation
{
    public double Latitude;
    public double Longitude;
    public double Altitude;

    public static ARObjectLocation FromLocationObj(Location location)
    {
        return new ARObjectLocation()
        {
            Latitude = location.Latitude,
            Longitude = location.Longitude,
            Altitude = location.Altitude
        };
    }
}

public class ARObject
{
    public string id;

    public bool isRequested;

    public GameObject content;

    public ARObjectLocation location;
}

public class UserInfo
{
    public string id;

    public string name;
}