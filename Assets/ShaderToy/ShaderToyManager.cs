using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderToyManager : MonoBehaviour
{
    public Shader PostProcessingShader;
    private Material mat;
    public Material Mat
    {
        get
        {
            //如果在面板中没有指定shader，则报错提示
            if (PostProcessingShader == null)
            {
                Debug.LogError("Shader没有指定!");
                return null;
            }

            //如果当前指定的shader不被支持的话，则报错提示
            if (!PostProcessingShader.isSupported)
            {
                Debug.LogError("Shader不支持!");
                return null;
            }

            //如果mat是空的，则创建一个新的材质球
            if (mat == null)
            {
                //新建一个材质球并返回
                Material _newMat = new Material(PostProcessingShader);
                _newMat.hideFlags = HideFlags.HideAndDontSave;
                mat = _newMat;
                return mat;
            }
            //如果mat存在，那就直接使用
            else
            {
                return mat;
            }
            

        }
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, Mat);
    }
    // Start is called before the first frame update

}
