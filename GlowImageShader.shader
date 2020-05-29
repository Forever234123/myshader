
Shader "Custom/GlowImageShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GlowColor("Glow Color",Color) = (0,0,0,1)
        _GlowSize("Glow Size",Range(0,5)) = 2.5
        _GlowStrength("Glow Strangth",Range(0,1)) = 0.7
        _AlphaCut("Alpha Cut",Range(0.1,0.999)) = 0.8
    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ShowOutline

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

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;

            float4 _GlowColor;
            fixed _GlowSize;
            fixed _GlowStrength;
            fixed _AlphaCut;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float a = 0;
				_GlowStrength /= 50.0;

                for (int x=-5; x<=5; x++)
                    for (int y=-5; y<=5; y++){
						fixed4 color = tex2D(_MainTex, i.uv + fixed2(x * _GlowSize * _MainTex_TexelSize.x, y * _GlowSize * _MainTex_TexelSize.y));
                         a += color.a * _GlowStrength * step(0,color.r+color.g+color.b);
					}
				            
                a = min(a, 1);
                fixed4 col2 = fixed4(_GlowColor.rgb, a * _GlowColor.a);
                fixed al = step(col.a,_AlphaCut);
                col = (1-al)*col + al*col2;
                return col;
            }
            ENDCG
        }
    }
}


