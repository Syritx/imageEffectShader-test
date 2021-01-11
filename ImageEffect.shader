Shader "Custom/ImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;

            float lerp(float a, float b, float w) {
                return pow(w,2) * (3-2*w) * (b-a) + a;
            }

            
            float2 generate_gradient(float a, float b) {
                float rand = 2920 * sin(a*21942 + b*171324 + 8912) * cos(a*23157 * b * 217832 + 6758);
                float2 gradient = float2(sin(rand), cos(rand));
                return gradient;
            }

            float dot_product(float2 p1, float2 p2) {
                float2 gradient = generate_gradient((int)p1.x, (int)p1.y);

                float x_dist = p2.x - (float)p1.x;
                float y_dist = p2.y - (float)p1.y;

                return (x_dist * gradient.x + y_dist * gradient.y);
            }
            

            float noise(float2 position) {
                int x0 = (int)position.x;
                float x1 = x0+1;

                int y0 = (int)position.y;
                float y1 = y0+1;

                float sx = position.x - (float)x0;
                float sy = position.y - (float)y0;

                float d1 = dot_product(float2(x0,y0), float2(position.x, position.y));
                float d2 = dot_product(float2(x1,y0), float2(position.x, position.y));
                float int_1 = lerp(d1, d2, sx);

                float d3 = dot_product(float2(x0,y1), float2(position.x, position.y));
                float d4 = dot_product(float2(x1,y1), float2(position.x, position.y));
                float int_2 = lerp(d3, d4, sx);

                return lerp(int_1, int_2, sy);
            }

            float noise_layer(float x, float y) {
                float n = 0;
                float freq = 2;
                float ampl = 1;

                n = noise(float2(x,y));
                return n;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float a = 0;
                a = noise_layer(i.vertex.y+_Time[0], sin(_Time[0]))*20;

                fixed4 col = tex2D(_MainTex, i.uv + float2(0, a)*.01);
                return col;
            }
            ENDCG
        }
    }
}
