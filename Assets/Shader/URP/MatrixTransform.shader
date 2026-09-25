Shader "xianze/URP/MatrixTransform"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _Translate("Translate", vector) = (0,0,0,0)
        _Scale("Scale(XYZ) Scale(W)", vector) = (1,1,1,1)
        _Rotation("Rotation", vector) = (0,0,0,0)
        [Header(View)]
        _ViewPos("ViewPos", vector) = (0,0,0,0)
        _ViewTarget("ViewTarget", vector) = (0,0,0,0)
        [Header(Camera)]
        [Enum(Orthographic,0,Perspective,1)]_CameraType("CameraType", float) = 1
        _CameraParas("Size(X) Near(Y) Far(Z) Bili(W)", vector) = (0,0,0,1.777)

    }
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"


            CBUFFER_START(UnityPerMaterial)
            half4 _Translate;
            half4 _Scale;
            half4 _Rotation;
            half4 _ViewPos;
            half4 _ViewTarget;
            float4 _CameraParas;
            half _CameraType;
            CBUFFER_END

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            
            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                //平移变换：顶点相加的计算方式
                // v.positionOS.xyz += _Translate.xyz;

                o.uv = v.uv;
                //矩阵平移方式
                float4x4 T = float4x4(
                1,0,0,_Translate.x,
                0,1,0,_Translate.y,
                0,0,1,_Translate.z,
                0,0,0,1
                );
                v.positionOS = mul(T,v.positionOS);

                //缩放变换
                // v.positionOS *= _Scale;
                float4x4 M_scale = float4x4(
                _Scale.x*_Scale.w,0,0,0,
                0,_Scale.y*_Scale.w,0,0,
                0,0,_Scale.z*_Scale.w,0,
                0,0,0,1
                );
                v.positionOS = mul(M_scale,v.positionOS);

                //旋转变换_X轴
                float4x4 M_rotationX = float4x4(
                1,0,0,0,
                0,cos(_Rotation.x),sin(_Rotation.x),0,
                0,-sin(_Rotation.x),cos(_Rotation.x),0,
                0,0,0,1
                );

                //旋转变换_Y轴
                float4x4 M_rotationY = float4x4(
                cos(_Rotation.y),0,sin(_Rotation.y),0,
                0,1,0,0,
                -sin(_Rotation.y),0,cos(_Rotation.y),0,
                0,0,0,1
                );

                //旋转变换_Z轴
                float4x4 M_rotationZ = float4x4(
                cos(_Rotation.z),sin(_Rotation.z),0,0,
                -sin(_Rotation.z),cos(_Rotation.z),0,0,
                0,0,1,0,
                0,0,0,1
                );

                v.positionOS = mul(M_rotationZ,mul(M_rotationY,mul(M_rotationX,v.positionOS)));

                
                //观察空间矩阵推导
                //P_view = [W_view] * P_world
                //P_view = [V_world]^-1 * P_world
                //P_view = [V_world]^T * P_world

                float3 ViewZ = normalize(_ViewPos - _ViewTarget);
                float3 ViewY = float3(0,1,0);
                float3 ViewX = cross(ViewZ,ViewY);
                ViewY = cross(ViewX,ViewZ);

                float4x4 M_view = float4x4(
                ViewX.x, ViewX.y, ViewX.z, 0,
                ViewY.x, ViewY.y, ViewY.z, 0,
                ViewZ.x, ViewZ.y, ViewZ.z, 0,
                0, 0, 0, 1
                );

                float4x4 M_viewTranslate = float4x4(
                1,0,0,-_ViewPos.x,
                0,1,0,-_ViewPos.y,
                0,0,1,-_ViewPos.z,
                0,0,0,1
                );
                float4x4 M_viewFinal = mul(M_view, M_viewTranslate);

                //本地空间变换到世界空间
                float3 positionWS = TransformObjectToWorld(v.positionOS);
                //世界空间变换到观察空间
                // float3 positionVS = TransformWorldToView(positionWS);
                float3 positionVS = mul(M_viewFinal, float4(positionWS,1));

                //正交投影矩阵
                //P_clip = [V_clip] * P_world

                
                float h = _CameraParas.x * 2;
                float r = _CameraParas.w;
                float w = h*r;
                float n = _CameraParas.y;
                float f = _CameraParas.z;

                float4x4 M_clipOrtho;
                if(UNITY_NEAR_CLIP_VALUE == -1)
                {
                    //opengl(-1,1)
                    M_clipOrtho = float4x4(
                    2/w,0,0,0,
                    0,2/h,0,0,
                    0,0,2/(n-f),(n+f)/(n-f),
                    0,0,0,1
                    );
                }
                

                if(UNITY_NEAR_CLIP_VALUE == 1)
                {
                    
                    //DirectX(0,1)
                    M_clipOrtho = float4x4(
                    2/w,0,0,0,
                    0,-2/h,0,0,
                    0,0,1/(f-n),f/(f-n),
                    0,0,0,1
                    );
                }


                //透视相机投影矩阵
                float4x4 M_clipPerspective;
                if(UNITY_NEAR_CLIP_VALUE == -1)
                {
                    //OpenGl(-1,1)
                    M_clipPerspective = float4x4(
                    2*n/w,0,0,0,
                    0,2*n/h,0,0,
                    0,0,(n+f)/(n-f),2*n*f/(n-f),
                    0,0,-1,0
                    );
                }
                if(UNITY_NEAR_CLIP_VALUE == 1)
                {
                    //DirectX(0,1)
                    M_clipPerspective = float4x4(
                    2*n/w,0,0,0,
                    0,-2*n/h,0,0,
                    0,0,f/(f-n),n*f/(f-n),
                    0,0,-1,0
                    );
                }

                float4x4 M_clip = _CameraType ? M_clipPerspective : M_clipOrtho;               //手动将观察空间变换到裁剪空间
                o.positionCS = mul(M_clip,float4(positionVS,1));

                //观察空间变换到裁剪空间
                // o.positionCS = TransformWViewToHClip(positionVS);

                // o.positionCS = TransformWorldToHClip(v.positionOS);
               
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return c;
            }
            ENDHLSL
        }
    }
}
