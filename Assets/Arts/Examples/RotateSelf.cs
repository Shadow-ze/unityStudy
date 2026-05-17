using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSelf : MonoBehaviour
{
    private Vector3 dirtion;
    public float speed = 1;
    // Start is called before the first frame update
    //先定义枚举的值
    public enum RotateDirection
    {
        X轴正方向,
        X轴负方向,
        Y轴正方向,
        Y轴负方向,
        Z轴正方向,
        Z轴负方向,

    }

    //声明具体的枚举变量
    public RotateDirection dir = RotateDirection.Y轴正方向;
    void Start()
    {
        switch(dir)
        {
            case RotateDirection.X轴正方向:
            dirtion = Vector3.right;
            break;
            case RotateDirection.X轴负方向:
            dirtion = Vector3.left;
            break;
            case RotateDirection.Y轴正方向:
            dirtion = Vector3.up;
            break;
            case RotateDirection.Y轴负方向:
            dirtion = Vector3.down;
            break;
            case RotateDirection.Z轴正方向:
            dirtion = Vector3.forward;
            break;
            case RotateDirection.Z轴负方向:
            dirtion = Vector3.back;
            break;

        }
    }

    // Update is called once per frame
    void Update()
    {
        
        transform.Rotate(dirtion, speed);
    }
}
