using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI; //引用UGUI代码库

public class GhostController : MonoBehaviour
{
    public Button SetColorBtn;
    public GameObject character;
    public Slider RotateSlider;
    void Start()
    {
        SetColorBtn.onClick.AddListener(OnSetColor);
        RotateSlider.onValueChanged.AddListener(OnRotateSlider);
    }

    // Update is called once per frame
    void OnSetColor()
    {
        float r = Random.value;
        float g = Random.value;
        float b = Random.value;
        character.GetComponentInChildren<SkinnedMeshRenderer>().sharedMaterial.SetColor("_FresnelColor", new Color(r,g,b,1));
    }

    
    void OnRotateSlider(float value)
    {
        character.GetComponent<RotateSelf>().speed = value;
    }
}
