using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fog : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    public float fogIntensity = 0f;
    void Update()
    {
        if(fogIntensity<1f)
        {
            fogIntensity += 0.01f;;
        }

        GetComponent<Renderer>().material.color = Color.Lerp(Color.black, Color.white, fogIntensity);
    }
}
