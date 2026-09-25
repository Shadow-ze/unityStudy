Shader "xianze/URP/Sequence"
{
    Properties
    {
        [Enum (UnityEngine.Rendering.BlendMode)]_SrcFactor("_SrcFactor",int) = 0
        [Enum (UnityEngine.Rendering.BlendMode)]_DstFactor("_DstFactor",int) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode", int) = 0
        _BaseColor("Base Color", color) = (1,1,1,0)
        _Sequence("Sequence", vector) = (1,1,1,0)
        _BaseMap("BaseMap",2D) = "white"{}
    }
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Transparent"

        }
        
        Blend [_SrcFactor] [_DstFactor]
        Cull [_Cull]
        Zwrite Off
        Pass
        {
            Name "Unlit"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half4 _Sequence;
            CBUFFER_END
            TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);float4 _BaseMap_ST;

            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
        
                //目的是为了构建旋转后的基向量在模型本地空间下的坐标
                //viewDir是定义的Z基向量，把相机从世界空间转换为本地空间，本地空间以模型为中心，相机转换后的位置就是Z基向量的方向
                // float3 viewDir = mul(GetWorldToObjectMatrix(), _WorldSpaceCameraPos);
                float3 cameraPosOS = TransformWorldToObject(_WorldSpaceCameraPos);
                //对向量归一化，求出基
                // viewDir = normalize(viewDir);
                float3 viewDir = normalize(cameraPosOS);
                //假设Y轴基向量
                float3 upDir = float3(0,1,0);
                //通过叉积求出X轴基向量（左手法则）
                float3 rightDir = normalize(cross(viewDir,upDir));
                //通过叉积反推出Y轴基向量
                upDir = normalize(cross(rightDir,viewDir));
                
                float3 newVertex = rightDir * v.positionOS.x + upDir * v.positionOS.y + viewDir * v.positionOS.z;

                o.positionCS = TransformObjectToHClip(newVertex);
                //uv的起始位置
                o.uv = float2(v.uv.x/_Sequence.y,v.uv.y/_Sequence.x+1/_Sequence.x*(_Sequence.x-1));
                //对U方向进行走格偏移
                o.uv.x += frac(floor(_Time.y * _Sequence.z)/_Sequence.y);
                //对V方向进行走格偏移
                o.uv.y -= frac(floor(_Time.y * _Sequence.z/_Sequence.y)/_Sequence.x);
                
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 c;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                c = baseMap * _BaseColor;

                return c;
            }
            ENDHLSL
        }
    }

    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue" = "Transparent"
        }   

        Blend [_SrcFactor] [_DstFactor]
        Cull [_Cull]
        Zwrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            sampler2D _BaseMap;
            float4 _BaseColor;
            half4 _Sequence;

            v2f vert (appdata v)
            {
                v2f o;
        
                float3 cameraPosOS = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos.xyz,1)).xyz;
                //对向量归一化，求出基
                // viewDir = normalize(viewDir);
                float3 viewDir = normalize(cameraPosOS);
                //假设Y轴基向量
                float3 upDir = float3(0,1,0);
                //通过叉积求出X轴基向量（左手法则）
                float3 rightDir = normalize(cross(viewDir,upDir));
                //通过叉积反推出Y轴基向量
                upDir = normalize(cross(rightDir,viewDir));
                
                float3 newVertex = rightDir * v.positionOS.x + upDir * v.positionOS.y + viewDir * v.positionOS.z;

                o.position = UnityObjectToClipPos(newVertex);
                //uv的起始位置
                o.uv = float2(v.uv.x/_Sequence.y,v.uv.y/_Sequence.x+1/_Sequence.x*(_Sequence.x-1));
                //对U方向进行走格偏移
                o.uv.x += frac(floor(_Time.y * _Sequence.z)/_Sequence.y);
                //对V方向进行走格偏移
                o.uv.y -= frac(floor(_Time.y * _Sequence.z/_Sequence.y)/_Sequence.x);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 c;
                half4 baseMap = tex2D(_BaseMap,  i.uv);
                c = baseMap * _BaseColor;

                return c;
            }
            ENDCG
        }
    }
}
