// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/Sun"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0,0,0,0)
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 9999999 , 9999999
		Stencil
		{
			Ref 222
			ReadMask 222
			WriteMask 12
			Comp NotEqual
			Pass Keep
			Fail Zero
			ZFail Zero
		}
		
		
		Pass
		{
			Name "Unlit"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform float4 _Color;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				//Calculate new billboard vertex position and normal;
				float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
				float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
				float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
				float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
				v.ase_normal = normalize( mul( float4( v.ase_normal , 0 ), rotationCamMatrix )).xyz;
				v.vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
				v.vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
				v.vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
				v.vertex = mul( v.vertex, rotationCamMatrix );
				v.vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
				//Need to nullify rotation inserted by generated surface shader;
				v.vertex = mul( unity_WorldToObject, v.vertex );
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue = 0;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float4 break16 = _Color;
				float2 uv07 = i.ase_texcoord.xy * float2( 1,1 ) + float2( -0.5,-0.5 );
				float temp_output_13_0 = ( ( 1.0 - ( length( uv07 ) * 2.09 ) ) * 19.6 );
				float4 appendResult17 = (float4(break16.r , break16.g , break16.b , saturate( temp_output_13_0 )));
				
				
				finalColor = appendResult17;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16702
2102;129;1728;1004;2438.158;377.2249;1.626672;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1458.014,359.6333;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.5,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;8;-1215.414,364.0332;Float;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;10;-1049.314,368.7333;Float;True;2.09;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-874.3135,368.1333;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1063.231,-153.2142;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;3,2.797116,1.544418,3;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleNode;13;-701.7135,366.4336;Float;True;19.6;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;16;-519.3237,55.46814;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;21;-412.6104,424.4697;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;17;-251.3237,70.46814;Float;False;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-1069.114,104.6333;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-629.231,-41.16144;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BillboardNode;5;-389.1136,-88.3667;Float;False;Spherical;True;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-676.3237,85.46814;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;40,-28;Float;False;True;2;Float;ASEMaterialInspector;0;1;LothsShade/Sun;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;True;222;False;-1;222;False;-1;12;False;-1;6;False;-1;1;False;-1;2;False;-1;2;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;9999999;False;-1;9999999;False;-1;True;1;RenderType=Transparent=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;0
WireConnection;10;0;8;0
WireConnection;11;0;10;0
WireConnection;13;0;11;0
WireConnection;16;0;2;0
WireConnection;21;0;13;0
WireConnection;17;0;16;0
WireConnection;17;1;16;1
WireConnection;17;2;16;2
WireConnection;17;3;21;0
WireConnection;19;0;2;0
WireConnection;19;1;13;0
WireConnection;18;0;3;0
WireConnection;18;1;2;0
WireConnection;1;0;17;0
WireConnection;1;1;5;0
ASEEND*/
//CHKSM=7590CCEF3AAD4E6D33AAE6C2B1EB9765D0A9766E