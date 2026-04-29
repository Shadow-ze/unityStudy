Shader "xianze/Effects"
{
    Properties
    {
        [Header(Rendering Mode)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend",int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend",int) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull",int) = 0
        [Enum(Off,0,On,1)]_ZWrite("ZWrite", int) = 0

        [Header(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Intensity ("Intensity", Range(0,6)) = 1
        _MainUVSpeedX ("MainUVSpeed X", float) = 0
        _MainUVSpeedY ("MainUVSpeed Y", float) = 0

        [Header(Mask)]
        [Toggle]_MaskEnabled("Mask Enable", int) = 0
        _MaskTex ("MaskTex", 2D) = "white" {}
        _MaskUVSpeedX ("MaskUVSpeed X", float) = 0
        _MaskUVSpeedY ("MaskUVSpeed Y", float) = 0

        [Header(Distort)]
        [MaterialToggle(DISTORTENABLED)]_DistortEnabled("Distort Enable", int) = 0
        _DistortTex ("DistortTex", 2D) = "white" {}
        _Distort ("Distort", Range(0,1)) = 0
        _DistortUVSpeedX ("DistortUVSpeed X", float) = 0
        _DistortUVSpeedY ("DistortUVSpeed Y", float) = 0



    }
    SubShader
    {        
        Tags{"Queue" = "Transparent"}
        Blend [_SrcBlend] [_DstBlend]
        Cull [_Cull]
        ZWrite [_ZWrite]

        // Pass
        // {
        //     Zwrite On
        //     ColorMask 0
        // }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ _MASKENABLED_ON
            #pragma shader_feature _ DISTORTENABLED
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;float4 _MainTex_ST;
            
            fixed4 _Color;
            half _Intensity;
            float _MainUVSpeedX,_MainUVSpeedY;
            sampler2D _MaskTex;float4 _MaskTex_ST;
            float _MaskUVSpeedX,_MaskUVSpeedY;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            float _DistortUVSpeedX,_DistortUVSpeedY;
            float _Distort;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + float2(_MainUVSpeedX,_MainUVSpeedY) * _Time.y;

                #if _MASKENABLED_ON
                    o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex) + float2(_MaskUVSpeedX,_MaskUVSpeedY) * _Time.y;
                #endif

                #if DISTORTENABLED
                    o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex) + float2(_DistortUVSpeedX,_DistortUVSpeedY) * _Time.y;
                #endif
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                col = _Color * _Intensity;
                float2 distort = i.uv.xy;

                #if DISTORTENABLED
                fixed4 distortTex = tex2D(_DistortTex, i.uv2);
                distort = lerp(i.uv.xy,distortTex,_Distort);
                #endif
                fixed4 mainTex = tex2D(_MainTex, distort);
                col *= mainTex;         

                #if _MASKENABLED_ON
                fixed4 maskTex = tex2D(_MaskTex, i.uv.zw);
                col *= maskTex;
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
