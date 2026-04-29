Shader "xianze/TextureTutorial"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(Repeat,Clamp)]_WrapMode("WrapMode", int) = 0
        [IntRange]_Mipmap("Mipmap", Range(0,10)) = 0
        [Normal]_NormalTex("NormalTex", 2D) = "bump"{}
        _CubeMap("Cube", CUBE) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma Shader_feature _WRAPMODE_REPEAT _WRAPMODE_CLAMP
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                half3 worldNormal : TEXCOORD3;

                //三个float3向量组合成切线转置矩阵
                float3 tSpace0:TEXCOORD4;
                float3 tSpace1:TEXCOORD5;
                float3 tSpace2:TEXCOORD6;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Mipmap;
            sampler2D _NormalTex;
            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.localPos = v.vertex.xyz;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                //切线转置矩阵的计算
                //切线从本地空间转换到世界空间
                half3 worldTangent = UnityObjectToWorldDir(v.tangent);
                //v.tangent.w决定副切线的方向
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                //由世界法线和切线叉积算出副切线
                half3 worldBinormal = cross(o.worldNormal, worldTangent) * tangentSign;
                o.tSpace0 = float3(worldTangent.x,worldBinormal.x,o.worldNormal.x);
                o.tSpace1 = float3(worldTangent.y,worldBinormal.y,o.worldNormal.y);
                o.tSpace2 = float3(worldTangent.z,worldBinormal.z,o.worldNormal.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //WrapMode
                #if _WRAPMODE_REPEAT
                i.uv = frac(i.uv);
                #elif _WRAPMODE_CLAMP

                //方法一
                //i.uv = clamp(i.uv,0,1);
                //方法二
                i.uv = saturate(i.uv);
                #endif

                //多级渐远Mipmap
                //tex2Dlod的第二个参数是四维向量，最后一个分量w表示的是采样级别
                float4 uvMipmap = float4(i.uv,0,_Mipmap);
                fixed4 c = tex2Dlod(_MainTex, uvMipmap);


                fixed3 normalTex = UnpackNormal(tex2D(_NormalTex,i.uv));
                //lambert max(0,dot(N,L))
                fixed3 N1 = normalize(normalTex);
                fixed3 L = _WorldSpaceLightPos0.xyz;


                //half3 normalTex = UnpackNormalWithScale(tex2D(_NormalTex,i.uv),scale);
                //通过矩阵相乘（利用点积）得出世界空间下的法线（法线纹理）
                half3 worldNormal = half3(dot(i.tSpace0,normalTex),dot(i.tSpace1,normalTex),dot(i.tSpace2,normalTex));
                //return max(0,dot(worldNormal,L));

                
                //cubeMap  准备V,R,N
                fixed3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 N = normalize(worldNormal);
                fixed3 R = reflect(-V,N);
                float4 cubemap = texCUBE(_CubeMap,R);
                return cubemap;

                // //反射探针中当前激活的CubeMap存储在unity_SpecCube0当中，必须要用UNITY_SAMPLE_TEXCUBE进行采样，然后需要对其进行解码
                // half3 worldView = normalize (UnityWorldSpaceViewDir (i.worldPos));
                // //half3 R = reflect (-worldView, N);
                // half4 cubemap = UNITY_SAMPLE_TEXCUBE (unity_SpecCube0, R);
                // half3 skyColor = DecodeHDR (cubemap, unity_SpecCube0_HDR);
                // return fixed4(skyColor,1);
            }
            ENDCG
        }
    }
}
