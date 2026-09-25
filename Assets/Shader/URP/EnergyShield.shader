Shader "xianze/URP/EnergyShield"
{
    Properties
    {
        _BaseColor("Base Color",color) = (1,1,1,1)
        _BaseMap ("Texture", 2D) = "white" {}
        _HightLightFade("Highlight Fade", float) = 1
        _HightLightColor("Highlight Color", color) = (1,1,1,1)
        _FresnelPower("FresnelPower", Range(0, 15)) = 1
        _FresnelColor("Fresnel Color", color) = (1,1,1,1)
        _EnergyInstensity("Energy Intensity", Range(0, 1)) = 1
        _Tiling("Tiling", float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline" 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "IgnoreProjector"="True"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            // Blend One One
            Name "Unlit"
            HLSLPROGRAM
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 positionVS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                half3 viewWS : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _HightLightFade;
            half4 _HightLightColor;
            half _FresnelPower;
            half4 _FresnelColor;
            half _EnergyInstensity;
            half _Tiling;
            float4 _BaseMap_ST;
            CBUFFER_END
            TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);
            // TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D (_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);


            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                //将顶点从本地空间转换为世界空间
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                //将顶点从世界空间转换为观察空间
                o.positionVS = TransformWorldToView(positionWS);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.viewWS = _WorldSpaceCameraPos - positionWS;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BaseMap);
                o.uv.xy = v.uv;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 c;
                // float2 screenUV = GetNormalizedScreenSpaceUV(i.positionCS);
                float2 screenUV = i.positionCS.xy / _ScreenParams.xy;
                half4 depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV);
                half depth = LinearEyeDepth(depthMap.r, _ZBufferParams);
                half4 highlight = depth + i.positionVS.z;
                // 深度差调试：交界处接近黑色，距离越远越白；Alpha 固定为 1。
                highlight = 1-saturate(highlight * _HightLightFade);
                highlight *= _HightLightColor;
                c = highlight;

                //Fresnel效果
                half3 N = normalize(i.normalWS);
                half3 V = normalize(i.viewWS);

                half NdotV = 1-max(0, dot(N, V));
                half4 fresnel = pow(abs(NdotV), _FresnelPower);
                fresnel *= _FresnelColor;
                c += fresnel;

                //当前帧的抓屏
                half4 screenColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV);


                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv.zw);
                c += baseMap * _EnergyInstensity;
                c += frac(i.uv.y * _Tiling + _Time.y);
                return c;
            }
            ENDHLSL
        }
    }
}
