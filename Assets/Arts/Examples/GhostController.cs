using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI; //引用UGUI代码库

public class GhostController : MonoBehaviour
{
    #region [成员变量]
    public Button SetColorBtn;
    public GameObject character;
    public Slider RotateSlider;
    public Slider RepeatXSlider;
    
    private Material CharacterMat;
    #endregion

    #region [Start]
    void Start()
    {
        SetColorBtn.onClick.AddListener(OnSetColor);
        RotateSlider.onValueChanged.AddListener(OnRotateSlider);
        RepeatXSlider.onValueChanged.AddListener(OnRepeatXSlider);
        CharacterMat = character.GetComponentInChildren<SkinnedMeshRenderer>().sharedMaterial;
    }
    #endregion

    #region [交互实现]
    // Update is called once per frame
    void OnSetColor()
    {
        float r = Random.value;
        float g = Random.value;
        float b = Random.value;
        CharacterMat.SetColor("_FresnelColor", new Color(r,g,b,1));
    }

    
    void OnRotateSlider(float value)
    {
        character.GetComponent<RotateSelf>().speed = value;
    }

    void OnRepeatXSlider(float value)
    {
        Vector4 _animation = CharacterMat.GetVector("_Animation");
        CharacterMat.SetVector("_Animation", new Vector4(value, _animation.y, _animation.z, _animation.w));
    }
    #endregion
}
