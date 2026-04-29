Shader "xianze/InstructionOptimization"
{
    Properties
    {
        _Value("Value", Vector) = (1,1,1,1)
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
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _Value;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float a = _Value.x;
                float b = _Value.y;
                float c = _Value.z;
                float d = _Value.w;

                //常量运算 不占用片段着色器指令数
                //return 5*2;

                //可以正常申请临时用的变量，对性能没有影响
                // float e0 = 5*2/0.2 + sin(1/5)/3;
                // float e1 = e0;
                // return e1;

                //基本运算
                float e2 = 5 + a;
                e2 = 5 - a;
                e2 = 5 * a;
                e2 = 5 / a;
                return e2;
            }
            ENDCG
        }
    }
}
