using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[RequireComponent(typeof(ARRaycastManager))]
public class InstantiateObject : MonoBehaviour
{
    private ARRaycastManager _arRayCastManager;
    static List<ARRaycastHit> hits = new List<ARRaycastHit>();


    public GameObject zombiePrefab;
    public GameObject boxPrefab;
    GameObject spawnedObject;
    Vector2 releasePosition;
    bool objectSelected = false;
    private string selectedObjectType;

    private UnityMessageManager messenger;

    void Awake()
    {
        _arRayCastManager = GetComponent<ARRaycastManager>();
        messenger = new UnityMessageManager();
    }

    void Update()
    {
        try
        {

            if (!TryGetTouchPosition(out Vector2 touchPosition))
            {
                return;
            }
            if (_arRayCastManager.Raycast(touchPosition, hits, TrackableType.PlaneWithinPolygon))
            {
                var hitPosition = new Vector3(-hits[0].pose.position.x, -hits[0].pose.position.y, -hits[0].pose.position.z);
                var hitRotation = hits[0].pose.rotation;

                if (objectSelected == true)
                {
                    GameObject gameObjectToInstantiate = GetGameObjectByTag(selectedObjectType);
                    spawnedObject = Instantiate(gameObjectToInstantiate, hitPosition, hitRotation);
                    messenger.SendMessageToFlutter(gameObjectToInstantiate.tag + "created");
                    objectSelected = false;

                }
                else
                {
                    messenger.SendMessageToFlutter(hitPosition.ToString());
                    spawnedObject.transform.position = hitPosition;
                }
            }

        }
        catch (Exception e)
        {
            messenger.SendMessageToFlutter(e.ToString());
        }


    }


    bool TryGetTouchPosition(out Vector2 touchPosition)
    {
        if (Input.touchCount > 0)
        {
            touchPosition = Input.GetTouch(0).position;
            return true;
        }
        touchPosition = default;
        return false;
    }

    public void ObjectSelected(string message)
    {
        string jsonString = message;

        ObjectSelectedMessage messageObject = ObjectSelectedMessage.CreateFromJSON(jsonString);

        selectedObjectType = messageObject.type;
        if (selectedObjectType == "none")
        {
            objectSelected = false;
        }
        else
        {
            objectSelected = true;
        }
        messenger.SendMessageToFlutter(selectedObjectType);
    }

    public GameObject GetGameObjectByTag(string tag)
    {
        switch (tag)
        {
            case "Zombie":
                return zombiePrefab;
            case "Box":
                return boxPrefab;
            case "none":
                return null;
            default:
                return null;
        }
    }
    [System.Serializable]
    public class ObjectSelectedMessage
    {
        public string type;
        public float posx;
        public float posy;

        public static ObjectSelectedMessage CreateFromJSON(string jsonString)
        {
            return JsonUtility.FromJson<ObjectSelectedMessage>(jsonString);
        }
    }
}
