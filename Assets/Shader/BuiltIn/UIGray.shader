Shader "xianze/UIGray"
{
    Properties
    {
        [PerRendererData]_MainTex("MainTex",2D) = "white"{}
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle]_GrayEnabled("Gray Enabled", int) = 0
    }

    SubShader
    {
        Tags{"Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
    
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ UNITY_UI_CLIP_RECT
            #pragma multi_compile _ _GRAYENABLED_ON
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                fixed4 color:COLOR;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                fixed4 color:COLOR;
                float4 vertex:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _ClipRect;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.vertex = v.vertex;
                return o;
            }


            fixed4 frag(v2f i) :SV_Target
            {
                fixed4 col;
                fixed4 mainTex = tex2D(_MainTex,i.uv);
                col = mainTex;
                col *= i.color;

                //使用step实现
                #if UNITY_UI_CLIP_RECT
                    // fixed2 rect = step(_ClipRect.xy,i.vertex.xy) * step(i.vertex.xy,_ClipRect.zw);
                    // col.a *= rect.x * rect.y;

                    
                //利用unity自带内置函数
                col.a *= UnityGet2DClipping(i.vertex,_ClipRect);
                #endif

                #if _GRAYENABLED_ON
                //方法去色公式
                //col.rgb = col.r * 0.22 + col.g * 0.707 + col.b * 0.071;

                //利用内置函数实现
                col.rgb = Luminance(col.rgb);
                #endif
                return col;
            }
            ENDCG
        }
    }
}
