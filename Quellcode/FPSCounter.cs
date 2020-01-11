/**
 * FPSCounter Klasse
 *
 * Simple FPS Anzeige Funktion die den Effekt der unterschiedlichen Tessellationsstufen verdeutlichen soll.
 * 
 * Autor: Martin Schuster 
 */

using UnityEngine;
using UnityEngine.UI;

public class FPSCounter : MonoBehaviour
{
    public Text displayFPS;
 
    public void Update ()
    {
        float current = 0;
        current = 1f / Time.deltaTime;
        displayFPS.text = "FPS: " + ((int)current).ToString();
    }
}
