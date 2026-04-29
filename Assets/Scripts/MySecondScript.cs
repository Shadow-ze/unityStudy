using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MySecondScript : MonoBehaviour
{
    #region [成员变量]
    public GameObject Cube;
    #endregion

    #region  [Start/Update]
    void Start()
    {
        // Cube = GameObject.Find("Cube");//private查找场景中的Cube物体
        MeshRenderer mr = Cube.GetComponent<MeshRenderer>();//var 关键词自动推断类型
        Debug.Log(mr.sharedMaterial);
    }

    // Update is called once per frame
    void Update()
    {
        // Cube.transform.position += new Vector3(0,0,0.01f);
        // Debug.Log(Cube.transform.position);
    }
    #endregion
}
