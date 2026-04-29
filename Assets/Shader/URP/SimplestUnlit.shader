Shader "xianze/URP/SimplestUnlit"
{
    Properties
    {
        _Color("Color",color) = (0,0,0,1)
        _MainTex("MainTex",2D) = "white"{}
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline" 
            "RenderType"="Opaque" 
            // "UniversalMaterialType" = "Unlit" 
            "Queue"="Geometry" 
        }

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
            
            // Render State
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            

            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            

            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI

            //新增
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX

            #define SHADERPASS SHADERPASS_UNLIT
            #define _FOG_FRAGMENT 1
            
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            CBUFFER_END

            //默认管线的纹理定义
            // sampler2D _MainTex;

            TEXTURE2D(_MainTex);
            float4 _MainTex_ST;
            //SAMPLER(sampler_MainTex);
            #define smp SamplerState_Linear_Repeat
            SAMPLER(smp);
            
            //顶点着色器的输入（模型的数据信息）
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD;
                
            };

            //顶点着色器的输出
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD;                
            };


            //顶点着色器
            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                float3 positionWS = TransformObjectToWorld(v.positionOS);
                o.positionCS = TransformWorldToHClip(positionWS);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            //片段着色器
            half4 frag(Varyings i) : SV_TARGET
            {
                half4 c;
                //默认管线的纹理采样操作
                // half4 mainTex = tex2D(_MainTex,i.uv); 

                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,smp,i.uv);

                c = mainTex * _Color;
                return c;
            }

            ENDHLSL
        }

    }

    FallBack "Hidden/Shader Graph/FallbackError"
}