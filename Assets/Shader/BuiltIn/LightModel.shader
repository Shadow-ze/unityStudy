Shader "xianze/LightModel"
{
    Properties
    {
        _DiffuseIntensity("Diffuse Intensity", float) = 1
        _SpecularColor("Specular Color", color) = (1,1,1,1)
        _SpecularIntensity("Specular Intensity", float) = 1
        _Shininess("Shininess", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }


        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            half _DiffuseIntensity;
            fixed4 _SpecularColor;
            half _SpecularIntensity,_Shininess;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;
                //Lambertian
                //Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L))
                float4 Ambient = unity_AmbientSky;
                half Kd = _DiffuseIntensity;
                fixed4 LightColor = _LightColor0;
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = _WorldSpaceLightPos0;
                fixed NDotL = dot(N,L);
                fixed4 Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L));
                col += Diffuse;

                //Phong
                //Specular = SpecularColor * Ks * pow(max(0,dot(R,V)), Shininess)
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                //计算反射向量的公式
                //float3 R = 2 * N * NDotL - L;
                //调用unity内置函数
                //float3 R = reflect(-L, N);
                //fixed4 Specular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(R,V)),_Shininess);
                //col += Specular;

                //Blinn-phong
                //Specular = SpecularColor * Ks * pow(max(0,dot(N,H)), Shininess)
                float3 H = normalize(L + V);
                fixed4 BlinnSpecular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(N,H)),_Shininess);
                col += BlinnSpecular;
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma skip_variants DIRECTIONAL DIRECTIONAL_COOKIE POINT_COOKIE
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // #if DIRECTIONAL
                // return 1;
                // #elif POINT
                // return fixed4(0,1,0,1);
                // #elif SPOT
                // return fixed4(0,0,1,1);
                // #endif
                //Diffuse = Ambient + Kd * LightColor * dot(N,L)

                //手写灯光衰减
                // float3 LightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                // fixed atten = tex2D(_LightTexture0,dot(LightCoord,LightCoord));

                //调用unity内置灯光函数
                UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos)

                fixed4 LightColor = _LightColor0 * atten;
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = _WorldSpaceLightPos0;
                fixed4 Diffuse = LightColor * max(0,dot(N,L));
                return Diffuse;
            }
            ENDCG
        }
    }
}
