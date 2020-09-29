using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoogleMapLoader : MonoBehaviour
{
    string mapUrl = "https://maps.googleapis.com/maps/api/staticmap?sensor=true&size=640x640";
    string key = "&key=AIzaSyCEZCXfxnmG2ZJgC9k5XJtNfopZJ78TTLI"; //put your own API key here.
    public GoogleMapLocation centerLocation;

    float MouseZoomSpeed = 5.0f;
    float TouchZoomSpeed = 0.1f;

    int zoom = 25;
    float newZoom = 25;

    float interval = 0.000001f;
    Vector2 oldPos = Vector2.zero;
    Vector2 centerOffset = Vector2.zero;

    // Start is called before the first frame update
    [System.Obsolete]
    void Start()
    {
        centerLocation = new GoogleMapLocation()
        {
            latitude = 46.765320,
            longitude = -71.263890
        };

        StartCoroutine(_LoadMap());
    }

    IEnumerator _LoadMap()
    {
        string url = mapUrl + "&center=" + WWW.UnEscapeURL(string.Format("{0},{1}", centerLocation.latitude, centerLocation.longitude));
        url += $"&zoom={zoom}";
        url += key;

        WWW www = new WWW(url);

        while (!www.isDone)
            yield return null;

        if (www.error == null)
        {
            Texture2D texture = (Texture2D)www.texture;

            this.GetComponent<SpriteRenderer>().sprite = Sprite.Create(texture, new Rect(0.0f, 0.0f, texture.width, texture.height), new Vector2(0.5f, 0.5f), 100.0f);
            this.GetComponent<SpriteRenderer>().material.mainTexture = www.texture;

            //www.LoadImageIntoTexture((Texture2D)this.GetComponent<Renderer>().material.mainTexture);
            // this.GetComponent<Renderer>().material.mainTexture = www.texture;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.touchSupported)
        {
            // Pinch to zoom
            if (Input.touchCount == 2)
            {
                // get current touch positions
                Touch tZero = Input.GetTouch(0);
                Touch tOne = Input.GetTouch(1);
                // get touch position from the previous frame
                Vector2 tZeroPrevious = tZero.position - tZero.deltaPosition;
                Vector2 tOnePrevious = tOne.position - tOne.deltaPosition;

                float oldTouchDistance = Vector2.Distance(tZeroPrevious, tOnePrevious);
                float currentTouchDistance = Vector2.Distance(tZero.position, tOne.position);

                // get offset value
                float deltaDistance = oldTouchDistance - currentTouchDistance;
                Zoom(deltaDistance, TouchZoomSpeed);
            } else if(Input.touchCount == 1)
            {
                Touch point = Input.GetTouch(0);
                Vector2 delta = point.position - point.deltaPosition;

                Move(delta.x, delta.y);
            }
        }
        else
        {
            float scroll = Input.GetAxis("Mouse ScrollWheel");
            Zoom(scroll, MouseZoomSpeed);

            if(Input.GetMouseButton(0))
            {
                Vector2 currentPos = Input.mousePosition;

                if (oldPos.x != 0 || oldPos.y != 0)
                {
                    float deltaX = currentPos.x - oldPos.x;
                    float deltaY = currentPos.y - oldPos.y;

                    Move(deltaX, deltaY);
                }

                oldPos = currentPos;
            }
        }
    }

    void Zoom(float deltaMagnitudeDiff, float speed)
    {
        newZoom += deltaMagnitudeDiff * speed;
        if((int)newZoom != zoom)
        {
            zoom = (int)newZoom;
            StartCoroutine(_LoadMap());
        }
    }

    void Move(float deltaX, float deltaY)
    {
        centerOffset.x += deltaX;
        centerOffset.y += deltaY;

        if(centerOffset.x > 200 || centerOffset.y > 200)
        {
            centerLocation.latitude -= centerOffset.y * interval * zoom;
            centerLocation.longitude -= centerOffset.x * interval * zoom;

            Debug.LogError(centerOffset);

            centerOffset = Vector2.zero;
        }

        StartCoroutine(_LoadMap());
    }

    [System.Serializable]
    public class GoogleMapLocation
    {
        public string address;
        public double latitude;
        public double longitude;
    }
}
