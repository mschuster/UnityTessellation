/**
 * ChangeEdgeLengthFactor Klasse
 *
 * Ermöglicht Benutzerinteraktion mit dem Shader.
 * 
 * Author: Martin Schuster
 */

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChangeEdgeLengthFactor : MonoBehaviour
{
    public Slider sliderTessellation;
    public Text sliderTessellationValue;
    public Slider sliderDisplacement;
    public Text sliderDisplacementValue;
    private GameObject _tesObject;

    private void Start()
    {
        _tesObject = GameObject.FindWithTag("Plane");
        _tesObject.GetComponent<Renderer>().material.SetInt("_EdgeLength", (int)sliderTessellation.value); 
        sliderTessellationValue.text = sliderTessellation.value.ToString();
        _tesObject.GetComponent<Renderer>().material.SetFloat("_DisplacementFactor", sliderDisplacement.value);
        sliderDisplacementValue.text = "0%";
    }
    public void ChangeEdgeLengthValue()
    {
        _tesObject.GetComponent<Renderer>().material.SetInt("_EdgeLength", (int)sliderTessellation.value); // Ermöglicht das ändern von dem EdgeLenthWert im Shader 
        sliderTessellationValue.text = sliderTessellation.value.ToString();
    }

    public void ChangeDisplacementValue()
    {
        _tesObject.GetComponent<Renderer>().material.SetFloat("_DisplacementFactor", sliderDisplacement.value); // Ermöglicht das ändern von dem Displacement Faktor im Shader 
        sliderDisplacementValue.text = (sliderDisplacement.value * 100).ToString("#") + " %";
    }
}
