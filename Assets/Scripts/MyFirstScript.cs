using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
// using xianze.math;//第二种方法引用命名空间
//[] = 可选项
//<> = 必选项
//[访问修饰符] class <类名(派生类)> [:继承(基类)]
namespace xianze.math
{
public class MyFirstScript : MonoBehaviour
{
    //public = 公有的
    //private = 私有的

    //变量命名规则：
    //首字母不能以数字和特殊符号开头
    //private通常用小驼峰命名：首字母小写，其他单词的首字母大写
    //public通常用大驼峰命名：所有单词的首字母都大写

    //变量类型
    //int = 整数
    //float = 浮点数
    //string = 字符串
    //bool = 布尔值(真/假)
    //vectorX = 向量
    //[访问修饰符] [const 常量标识符] <变量类型> <变量名称> [=默认值] <;>
   

    private string startText;
    // private const string startText = "游戏一开始时执行一次！";
    private string updateText;
    // private const string updateText = "游戏运行后每帧都会执行。";

    // public float Number01;
    // public float Number02;
    // public float Number03;

    public float[] Numbers = new float []{1,2,3,4,5,6,7,8,9};//数组
    public Vector4 Number;

    // public Vector2 Number;

    //方法的默认访问修饰符=private
    //[访问修饰符] <返回类型> <方法名称> ([参数列表])
    void Start()
    {
        // startText = "游戏一开始时执行一次！";
        // updateText = "游戏运行后每帧都会执行。";
        // AddNumber();

        // Log(startText);
    }

    // Update is called once per frame
    
    void Update()
    {
        // Log();
    }

    void OnGUI()
    {
       if (GUI.Button(new Rect(20,20,200,60),"计算"))
        {
            // PostProcessingManager ppm = new PostProcessingManager();//获取实例化
            // ppm.Age = 90;
            // Debug.Log(ppm.Age);
            // //类在使用前需实例化
            // MyMath myMath = new MyMath();//第一种方法直接引用命名空间
            // float value = myMath.Add(Number.x,Number.y,Number.z,Number.w);
            // Debug.Log(value);

            // while(Number01<10)
            // {
            //     Debug.Log(Number01);
            //     Number01++;

            // }

            //先执行再判断
            // do
            // {
            //     Debug.Log(Number01);
            //     Number01++;
            // }
            // while(Number01<10);

            // for(int i=0;i<10;i++)
            // {
            //         Debug.Log(i);
            // }

            // foreach(float i in Numbers)
            // {
            //     Debug.Log(i);
            // }
            Debug.Log("继续往下执行");
            //赋值运算符
            //+ - * / ++ --
            // float value = Number01;
            // Number01 /= Number02;
            // Number01++; //赋值运算：Nunber01 = Number01 + 1

            //关系运算符 常用于分支判断
            //== != > < >= <=
            // bool value = Number01<=Number02;

            //逻辑运算符
            //&& || !
            // bool value = (Number01==Number02) || (Number01==Number03);
            // bool value = !(Number01==Number02);

            // if(Number01==Number02)
            // {
            //     Debug.Log("Number01和Number02相等");
            // }
            // else
            // {
            //     Debug.Log("Number01和Number02不相等");
            // }
            // Debug.Log("条件判断");

            // 
            
            

            }
        }
    }
}
    //<变量类型1> <变量名称1> [=默认值1],<变量类型2> <变量名称2> [=默认值2],...
    // void Log(string txt = "游戏开始！")
    // {
    //     Debug.Log(txt);
    // }

    // float AddNumber()
    // {
    //     float value = Number01 + Number02;
    //     // float value = Number.x + Number.y;
    //     return value;
    //     // Debug.Log(value);
    // }

