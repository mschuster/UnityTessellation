/**
 * LightMovement Klasse
 *
 * Ermöglicht die Bewegung der Lichtquelle mit der Mausbewegung des Nutzers.
 * Zudem kann mit dem Mausrad die Entfernung der Lichtquelle zum Objekt beeinflusst werden.
 * 
 * Author: Martin Schuster 
 */

using UnityEngine;

public class LightMovement : MonoBehaviour
{
    public Light light;
    public float depth = 1f;
    public Camera mousePlane;
    public GameObject plane;
    
    void Update()
    {
        var mousePos = Input.mousePosition;
        var wantedPos = mousePlane.ScreenToWorldPoint( new Vector3(mousePos.x, mousePos.y, depth)); 
        light.transform.localPosition = wantedPos;

        if (Input.GetAxis("Mouse ScrollWheel") > 0f)
        {
            depth += 0.25f;
        }
        if (Input.GetAxis("Mouse ScrollWheel") < 0f)
        {
            depth -= 0.25f;
        }
    }
}
