Shader "xianze/URP/Ghost"
{
    Properties
    {
        _Fresnel("Fade(X) Intensity(Y) TopMask(Z) Offset(w)", vector) = (0,0,0,0)
        _FresnelColor("FresnelColor", color) = (1,1,1,0)
        _Animation("Repeat(XZ) Extent(YW)", vector) = (0,0,0,0)
    }
    //urp
    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Transparent"
            // "RenderType"="Transparent" 
        }
        Blend One One
        Zwrite Off

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


            struct Attributes
            {
                float4 vertexOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 vertexCS : SV_POSITION;
                float3 normalWS : TEXCOORD;
                float3 vertexWS : TEXCOORD1;
                float4 vertexOS : TEXCOORD2;
            };


            CBUFFER_START(UnityPerMaterial)
            half4 _Fresnel;
            half4 _FresnelColor;
            half4 _Animation;
            
            CBUFFER_END
            Varyings vert (Attributes v)
            {
                Varyings o;
                o.vertexOS = v.vertexOS;
                v.vertexOS.x += sin((v.vertexOS.y+_Time.y)*_Animation.x)*_Animation.y;
                v.vertexOS.z += sin((v.vertexOS.y+_Time.y)*_Animation.z)*_Animation.w;
                o.vertexCS = TransformObjectToHClip(v.vertexOS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.vertexWS = TransformObjectToWorld(v.vertexOS);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                //max(0,dot(N,V))  
                half3 N = normalize(i.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - i.vertexWS);
                half dotNV = 1-saturate(dot(N,V));
                half4 fresnel = pow(dotNV,_Fresnel.x) * _Fresnel.y * _FresnelColor;
                
                //从上到下的黑白遮罩
                half mask = saturate(i.vertexOS.y + i.vertexOS.z + _Fresnel.w);

                half4 c;
                fresnel = lerp(fresnel,_FresnelColor * mask,mask * _Fresnel.z);
                c = fresnel * mask;
                return c;
            }
            ENDHLSL
        }
    }

    //Built in
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "RenderType"="Transparent" 
        }
        Blend One One
        Zwrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            


            struct Attributes
            {
                float4 vertexOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 vertexCS : SV_POSITION;
                float3 normalWS : TEXCOORD;
                float3 vertexWS : TEXCOORD1;
                float4 vertexOS : TEXCOORD2;
            };


            half4 _Fresnel;
            half4 _FresnelColor;
            half4 _Animation;
            
            Varyings vert (Attributes v)
            {
                Varyings o;
                o.vertexOS = v.vertexOS;
                v.vertexOS.x += sin((v.vertexOS.y+_Time.y)*_Animation.x)*_Animation.y;
                v.vertexOS.z += sin((v.vertexOS.y+_Time.y)*_Animation.z)*_Animation.w;
                o.vertexCS = UnityObjectToClipPos(v.vertexOS);
                o.normalWS = UnityObjectToWorldNormal(v.normalOS);
                o.vertexWS = mul(unity_ObjectToWorld,v.vertexOS);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                //max(0,dot(N,V))  
                half3 N = normalize(i.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - i.vertexWS);
                half dotNV = 1-saturate(dot(N,V));
                half4 fresnel = pow(dotNV,_Fresnel.x) * _Fresnel.y * _FresnelColor;
                
                //从上到下的黑白遮罩
                half mask = saturate(i.vertexOS.y + i.vertexOS.z + _Fresnel.w);

                half4 c;
                fresnel = lerp(fresnel,_FresnelColor * mask,mask * _Fresnel.z);
                c = fresnel * mask;
                return c;
            }
            ENDCG
        }
    }
}
