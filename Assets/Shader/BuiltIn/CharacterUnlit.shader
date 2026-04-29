 Shader "xianze/CharacterUnlit"
{
    Properties
    {
        //[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", int) = 0
        [Header(Base)]
        [NoScaleOffset]_MainTex("MainTex",2D) = "white" {}
        _Color("Color",color) = (0,0,0,1)

        [Header(Dissolve)]
        [Toggle]_DissolveEnabled("Dissolve Enabled",int) = 0
        _DissolveTex("DissolveTex(R)",2D) = "white" {}
        [NoScaleOffset]_RampTex("RampTex(RGB)",2D) = "white" {}
        _Clip("Clip",Range(0,1)) = 0

        [Header(Shadow)]
        _Shadow("Offset(XZ) Height(Y) Alpha(W)", vector) = (0,0,0,0)
    }
    
    SubShader
    {
        Tags{"Queue" = "Geometry"}
        LOD 600
        Blend off
        Cull Back
        Offset 0,0
        //ZWrite On
        //ZTest [_ZTest]

        
        
        UsePass "xianze/XRay/XRAY"
        
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #pragma multi_compile_fwdbase
            #pragma skip_variants  LIGHTPROBE_SH SHADOWS_SHADOWMASK DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING DIRLIGHTMAP_COMBINED  VERTEXLIGHT_ON
            //#pragma multi_compile DIRECTIONAL SHADOWS_SCREEN//有问题，把投影也剔除了
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"


            sampler2D _MainTex;
            sampler2D _DissolveTex; float4 _DissolveTex_ST;
            fixed4 _Color;
            fixed _Clip;
            sampler _RampTex;//性能优化，没有采样到y轴，减少运算

            struct appdata
            {
                float4 vertex   :POSITION;
                float4 uv       :TEXCOORD;
            };

            struct v2f
            {
                float4 pos   :SV_POSITION;
                float4 uv    :TEXCOORD;//xy zw两个二维共用一套，节省性能
                float4 worldPos : TEXCOORD1;
                UNITY_SHADOW_COORDS(2)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                //o.uv.zw = v.uv*_DissolveTex_ST.xy+_DissolveTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                fixed4 col;
                fixed4 tex = tex2D(_MainTex,i.uv.xy);
                col = tex * atten;
                col += _Color;

                #if _DISSOLVEENABLED_ON
                fixed4 dissolveTex = tex2D(_DissolveTex,i.uv.zw);
                clip(dissolveTex.r-_Clip);
                fixed dissolveValue = saturate((dissolveTex.r-_Clip)/(_Clip+0.1-_Clip));//使用线性插值代替smoothstep，优化性能
                fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                col += rampTex;
                #endif

                return col;
            }
            ENDCG
        }

            // 1.在v2f中添加UNITY_SHADOW_COORDS(idx),unity会自动声明一个叫_ShadowCoord的float4变量，用作阴影的采样坐标.
            // 2.在顶点着色器中添加TRANSFER_SHADOW(o)，用于将上面定义的_ShadowCoord纹理采样坐标变换到相应的屏幕空间纹理坐标，为采样阴影纹理使用.
            // 3.在片断着色器中添加UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)，其中atten即存储了采样后的阴影.
        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal  : NORMAL;
                float4 uv     : TEXCOORD;
            };

            struct v2f
            {
                float4 uv : TEXCOORD;
                V2F_SHADOW_CASTER;
            };

            sampler2D _DissolveTex; float4 _DissolveTex_ST;
            fixed _Clip;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                #if _DISSOLVEENABLED_ON
                fixed4 dissolveTex = tex2D(_DissolveTex,i.uv.zw);
                clip(dissolveTex.r-_Clip);
                #endif

                SHADOW_CASTER_FRAGMENT(i)
            }
            // 添加"LightMode" = "ShadowCaster"的Pass.
            // 1.appdata中声明float4 vertex:POSITION;和half3 normal:NORMAL;这是生成阴影所需要的语义.
            // 2.v2f中添加V2F_SHADOW_CASTER;用于声明需要传送到片断的数据.
            // 3.在顶点着色器中添加TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)，主要是计算阴影的偏移以解决不正确的Shadow Acne和Peter Panning现象.
            // 4.在片断着色器中添加SHADOW_CASTER_FRAGMENT(i)

            ENDCG
        }
    }

    SubShader
    {
        //Unity bug 会读取ShaderCaster，造成两个阴影
        LOD 400
        pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #pragma multi_compile_fwdbase
            #pragma skip_variants  LIGHTPROBE_SH SHADOWS_SHADOWMASK DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING DIRLIGHTMAP_COMBINED  VERTEXLIGHT_ON
            //#pragma multi_compile DIRECTIONAL SHADOWS_SCREEN//有问题，把投影也剔除了
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"


            sampler2D _MainTex;
            sampler2D _DissolveTex; float4 _DissolveTex_ST;
            fixed4 _Color;
            fixed _Clip;
            sampler _RampTex;//性能优化，没有采样到y轴，减少运算

            struct appdata
            {
                float4 vertex   :POSITION;
                float4 uv       :TEXCOORD;
            };

            struct v2f
            {
                float4 pos   :SV_POSITION;
                float4 uv    :TEXCOORD;//xy zw两个二维共用一套，节省性能
                
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                //o.uv.zw = v.uv*_DissolveTex_ST.xy+_DissolveTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                
                fixed4 col;
                fixed4 tex = tex2D(_MainTex,i.uv.xy);
                col = tex;
                col += _Color;

                #if _DISSOLVEENABLED_ON
                fixed4 dissolveTex = tex2D(_DissolveTex,i.uv.zw);
                clip(dissolveTex.r-_Clip);
                fixed dissolveValue = saturate((dissolveTex.r-_Clip)/(_Clip+0.1-_Clip));//使用线性插值代替smoothstep，优化性能
                fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                col += rampTex;
                #endif

                return col;
            }
            ENDCG
        }
        
        pass
        {
            Tags {"Queue" = "Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
            
            Stencil
            {
                Ref 100
                Comp NotEqual
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex  :POSITION;
            };

            struct v2f
            {
                float4 pos   :SV_POSITION;
            };

            float4 _Shadow;

            v2f vert(appdata v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float worldPosY = worldPos.y;
                worldPos.y = _Shadow.y;
                worldPos.xz += _Shadow.xz * (worldPosY - _Shadow.y);
                o.pos = mul(UNITY_MATRIX_VP,worldPos);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c = 0;
                c.a = _Shadow.w;
                return c;
            }


            ENDCG
        }
    }
    // Fallback "Legacy Shaders/VertexLit"
}
