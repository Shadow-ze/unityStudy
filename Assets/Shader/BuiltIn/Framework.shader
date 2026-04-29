Shader "xianze/Framework"
{
    
    SubShader
    {        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 color  : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                fixed4 value = fixed4(0.5,0.2,2,0.8);
                return value;
            }
            ENDCG
        }
    }
}
