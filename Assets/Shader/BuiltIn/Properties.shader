Shader "Unlit/Properties"
{
    Properties
    {
        [Header(Color)]
        [HDR]_Color("颜色",color) = (1,1,1,1)
        [Toggle]_Int("整数",int) = 0.5
        [IntRange]_Float("浮点值",range(0,10)) = 0.5

        [Space(10)]
        [Header(vector)]
        _Vector("四维向量",vector) = (0.5,2,1,1)
        [NoScaleOffset]_2DTex("2D纹理",2D) = "white"{}
    }
    SubShader
    {        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            int _Int;
            float _Float;
            float4 _Vector;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Vector;
            }
            ENDCG
        }
    }
}
