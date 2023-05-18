Shader "Unlit/ProjectorDecal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            float4x4 _DecalVPMatrix;
            float3 _DecalProjectorDir;

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                float4 uvDecal : TEXCOORD1;
                float clipV : TEXCOORD2;
                UNITY_FOG_COORDS(3)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                float4x4 decalMVP = mul(_DecalVPMatrix, unity_ObjectToWorld);
                float4 decalProjectionPos = mul(decalMVP, v.vertex);
                o.uvDecal = ComputeScreenPos(decalProjectionPos);

                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.clipV = dot(worldNormal, _DecalProjectorDir);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(i.clipV - 0.05);
                
                float4 uv = i.uvDecal;

                uv = uv/uv.w;

                clip(uv.x);
                clip(uv.y);
                clip(uv.z);
                clip(1-uv.x);
                clip(1-uv.y);
                clip(1-uv.z);

                uv.xy = TRANSFORM_TEX(uv.xy, _MainTex);

                //fixed4 col = tex2Dproj(_MainTex, uv);
                fixed4 col = tex2D(_MainTex, uv);
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
