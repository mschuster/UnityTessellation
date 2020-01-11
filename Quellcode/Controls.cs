/**
 * Controls Klasse
 *
 * Beendet das Programm mit dem Betätigen der Escape-Taste.
 * 
 * Autor: Martin Schuster
 */
using UnityEngine;

public class Controls : MonoBehaviour
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
        }
    }
}
