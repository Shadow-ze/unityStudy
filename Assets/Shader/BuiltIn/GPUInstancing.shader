Shader "xianze/GPUInstancing"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //在顶点着色器的输入定义INSTANCE_ID
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 wPos : TEXCOORD4;
                //在顶点着色器的输出定义INSTANCE_ID
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            //声明常量寄存器，并且在其中存储需要的变量属性
            UNITY_INSTANCING_BUFFER_START(prop)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            UNITY_INSTANCING_BUFFER_END(prop)
            

            v2f vert (appdata v)
            {
                //在顶点着色器中设置相应的instanceID,默认的坐标变换会自动支持实例化
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                //把instanceID从顶点着色器传到片段着色器
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //在片段着色器设置相应的instanceID
                UNITY_SETUP_INSTANCE_ID(i);
                //UNITY_ACCESS_INSTANCED_PROP，调用常量寄存器中的属性值
                return i.wPos.y*0.12 + UNITY_ACCESS_INSTANCED_PROP(prop, _Color);
            }
            ENDCG
        }
    }
}
