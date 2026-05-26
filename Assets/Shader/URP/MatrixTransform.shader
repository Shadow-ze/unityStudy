Shader "xianze/URP/MatrixTransform"
{
    Properties
    {
        _Translate("Translate", vector) = (0,0,0,0)
        _Scale("Scale(XYZ) Scale(W)", vector) = (1,1,1,1)
        _Angle("Angle", float) = 0
    }
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"


            CBUFFER_START(UnityPerMaterial)
            half4 _Translate;
            half4 _Scale;
            half _Angle;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            
            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                //平移变换：顶点相加的计算方式
                // v.positionOS.xyz += _Translate.xyz;

                //矩阵平移方式
                float4x4 T = float4x4(
                1,0,0,_Translate.x,
                0,1,0,_Translate.y,
                0,0,1,_Translate.z,
                0,0,0,1
                );
                v.positionOS = mul(T,v.positionOS);

                //缩放变换
                // v.positionOS *= _Scale;
                float4x4 M_scale = float4x4(
                _Scale.x*_Scale.w,0,0,0,
                0,_Scale.y*_Scale.w,0,0,
                0,0,_Scale.z*_Scale.w,0,
                0,0,0,1
                );
                v.positionOS = mul(M_scale,v.positionOS);

                //旋转变换
                float2x2 Angle = float2x2(
                cos(_Angle),sin(_Angle),
                -sin(_Angle),cos(_Angle)
                );
                v.positionOS.xy = mul(Angle,v.positionOS.xy);
                o.positionCS = TransformWorldToHClip(v.positionOS);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {

                return 1;
            }
            ENDHLSL
        }
    }
}
