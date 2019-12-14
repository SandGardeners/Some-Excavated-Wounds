// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DistanceBlur"
{
	Properties
	{
		
	}

	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			
		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;

			
			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoord;
				float4 ase_ppsScreenPosNorm = float4(o.texcoord,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosNorm = float4(i.texcoord,0,1);

				float clampDepth68 = Linear01Depth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( ase_ppsScreenPosNorm )));
				float4 temp_cast_0 = (clampDepth68).xxxx;
				

				float4 color = temp_cast_0;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16702
2154;129;1504;1044;445.1473;-870.1025;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;54;-1091.203,797.9014;Float;False;945.7418;324.2329;;5;13;52;56;51;53;Render Texture Pos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1083.5,1186.304;Float;False;892.3016;309.8983;;5;15;23;16;14;57;TilePos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1105.602,2427.499;Float;False;732.6016;286.6998;;4;4;2;3;5;Radius;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;34;-1114.293,1604.201;Float;False;935.8;371.1958;Comment;5;31;30;28;32;62;TileCenter;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1119.996,2034.6;Float;False;875.4005;286.4006;;5;41;35;36;58;37;Dist;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-1118.101,2802.498;Float;False;984.5472;358.8164;;5;25;61;24;19;18;TileUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-1131.414,3256.063;Float;False;996.2981;603.1008;;7;43;45;46;60;47;11;10;Fetch Render Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-571.9017,927.8;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-422.5938,1253.902;Float;False;TilePos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-1084.6,2216.999;Float;False;56;FragmentPos;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-1100.996,2094.6;Float;False;32;TileCenter;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1020.891,1659.201;Float;False;23;TilePos;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-1054.702,1250.802;Float;False;56;FragmentPos;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;53;-772.6025,882.0006;Float;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;14;-642.3983,1262.8;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1043.398,1005.497;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-1706.021,1487.344;Float;False;Property;_TileSize;TileSize;0;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;68;30.34877,1029.566;Float;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-533.2963,1383.305;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1013.493,1860.399;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-589.6921,1749.599;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;77;-69.33643,1462.082;Float;False;ScreenspaceUV;1;;1;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.LengthOpNode;35;-640.0961,2136.2;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;19;-811.5981,2977.897;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-822.2004,1318.003;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;76;-90.03625,1274.593;Float;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-421.4933,1718.202;Float;False;TileCenter;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1112.114,3760.465;Float;False;25;TileUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;18;-1062.101,2972.099;Float;False;0;0;_MainTex_TexelSize;Pass;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;52;-1042.203,833.9011;Float;False;0;0;_MainTex_TexelSize;Pass;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-448.6937,2956.698;Float;False;TileUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-790.4005,2524.299;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1070.496,2859.599;Float;False;32;TileCenter;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-481.8944,2177.598;Float;False;dist;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-367.701,946.3978;Float;False;FragmentPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;60;-827.7154,3491.362;Float;False;Property;_InBetweenColor;InBetweenColor;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-774.4122,3335.363;Float;False;41;dist;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-829.8955,1769.295;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;11;-1102.313,3629.967;Float;False;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-1055.602,2577.499;Float;False;Property;_RadiusTweak;RadiusTweak;4;0;Create;True;0;0;False;0;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-840.4964,2131.4;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-616.0007,2599.199;Float;False;Radius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-29.81953,1652.804;Float;False;Property;_Float2;Float 2;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-773.212,3407.163;Float;False;5;Radius;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;74;230.4585,1262.721;Float;False;return DownsampleBox13Tap(TEXTURE2D_PARAM(_MainTex, sampler_MainTex), i.texcoord,  _MainTex_TexelSize.xy)@;1;False;1;True;In0;FLOAT4;0,0,0,0;In;;Float;False;My Custom Expression;True;False;0;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-900.6134,3658.766;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1038.502,2494.4;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-629.6017,2869.992;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;43;-516.9115,3434.26;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;67;775.7518,1152.017;Float;False;True;2;Float;ASEMaterialInspector;0;2;DistanceBlur;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;51;0;53;0
WireConnection;51;1;13;0
WireConnection;23;0;16;0
WireConnection;14;0;15;0
WireConnection;16;0;14;0
WireConnection;16;1;1;0
WireConnection;30;0;31;0
WireConnection;30;1;62;0
WireConnection;35;0;36;0
WireConnection;15;0;57;0
WireConnection;15;1;1;0
WireConnection;32;0;30;0
WireConnection;25;0;61;0
WireConnection;3;0;4;0
WireConnection;3;1;2;0
WireConnection;3;2;1;0
WireConnection;41;0;35;0
WireConnection;56;0;51;0
WireConnection;62;0;1;0
WireConnection;62;1;28;0
WireConnection;36;0;37;0
WireConnection;36;1;58;0
WireConnection;5;0;3;0
WireConnection;74;0;76;0
WireConnection;10;1;47;0
WireConnection;61;0;24;0
WireConnection;61;1;19;0
WireConnection;43;0;45;0
WireConnection;43;1;46;0
WireConnection;43;2;60;0
WireConnection;43;3;10;0
WireConnection;43;4;10;0
WireConnection;67;0;68;0
ASEEND*/
//CHKSM=2F8AF477ED0507845569897E06A2237D64E1828B