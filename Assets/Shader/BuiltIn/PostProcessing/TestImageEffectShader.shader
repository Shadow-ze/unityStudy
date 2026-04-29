Shader "Hidden/TestImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // _Value ("Value", float) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed _Value;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return step(_Value,col.r);
            }
            ENDCG
        }
    }
}
