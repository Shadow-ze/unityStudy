Shader "Hidden/DefaultShaderToy"
{
    Properties
    {

    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = 0.5 + 0.5 * cos(_Time.y + i.uv.xyx + float3(0,2,4));
                return float4(col,1);

            }
            ENDCG

            // void mainImage( out vec4 fragColor, in vec2 fragCoord )
            // {
                //     // Normalized pixel coordinates (from 0 to 1)
                //     vec2 uv = fragCoord/iResolution.xy;

                //     // Time varying pixel color
                //     vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

                //     // Output to screen
                //     fragColor = vec4(col,1.0);
            // }
        }
    }
}
