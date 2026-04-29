Shader "xianze/XRay"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
            Name "XRAY"
            Tags { "Queue"="Transparent" }
            Blend One One
            ZTest Greater
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            fixed4 _Color;

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
                fixed4 col = 1;
                fixed3 N = normalize(i.worldNormal);
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed VdotN = dot(V,N);
                fixed fresnel = 2 * pow(1-VdotN,2);
                col = fresnel * _Color;

                fixed v = frac(i.worldPos.y*10 + _Time.y);
                col *= v;
                return col;
            }
            ENDCG
        }
    }
}
