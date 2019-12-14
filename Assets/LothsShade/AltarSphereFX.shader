// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/AltarSphereFX"
{
	Properties
	{
		_MainNoise("MainNoise", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (1,1,1,0)
		_Tiling("Tiling", Float) = 1
		_Cutoff( "Mask Clip Value", Float ) = 1
		_Falloff("Falloff", Float) = 0
		_Offset("Offset", Float) = 0
		_Speed("Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _MainColor;
		uniform sampler2D _MainNoise;
		uniform float _Tiling;
		uniform float _Speed;
		uniform float _Falloff;
		uniform float _Offset;
		uniform float _Cutoff = 1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _MainColor.rgb;
			o.Alpha = 1;
			float2 temp_cast_1 = (_Tiling).xx;
			float2 uv_TexCoord4 = i.uv_texcoord * temp_cast_1;
			float2 temp_cast_2 = (( _Time.y * _Speed )).xx;
			float4 temp_cast_3 = (0.0).xxxx;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 lerpResult8 = lerp( tex2D( _MainNoise, ( uv_TexCoord4 - temp_cast_2 ) ) , temp_cast_3 , ( ( ase_vertex3Pos.y * _Falloff ) + _Offset ));
			clip( lerpResult8.r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16702
2349;387;1233;663;3568.667;1626.304;4.233882;True;False
Node;AmplifyShaderEditor.RangedFloatNode;16;-1835.569,-208.7775;Float;False;Property;_Tiling;Tiling;2;0;Create;True;0;0;False;0;1;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1713.341,125.1406;Float;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1603.08,-37.00677;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1529.77,-195.4056;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;9;-1105.036,228.4245;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1242.341,311.1406;Float;False;Property;_Falloff;Falloff;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1551.341,92.14056;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-650.3408,542.1406;Float;False;Property;_Offset;Offset;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-1276.45,-7.67926;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-761.3408,241.1406;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1096.326,138.0407;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-615.3408,293.1406;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1025.077,-132.6112;Float;True;Property;_MainNoise;MainNoise;0;0;Create;True;0;0;False;0;cd460ee4ac5c1e746b7a734cc7cc64dd;a8b878977ce6a9442a7ec72550708ca1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-306.6953,-365.1787;Float;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;False;0;1,1,1,0;4,4,4,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-269.4968,521.5762;Float;False;Property;_MaskClipValue;MaskClipValue;7;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;-584.3262,-7.95929;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;14;-951.7197,404.3329;Float;True;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-1319.45,422.3207;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;LothsShade/AltarSphereFX;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;1;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;23;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;16;0
WireConnection;21;0;3;0
WireConnection;21;1;22;0
WireConnection;15;0;4;0
WireConnection;15;1;21;0
WireConnection;17;0;9;2
WireConnection;17;1;18;0
WireConnection;19;0;17;0
WireConnection;19;1;20;0
WireConnection;1;1;15;0
WireConnection;8;0;1;0
WireConnection;8;1;7;0
WireConnection;8;2;19;0
WireConnection;14;0;13;0
WireConnection;0;2;2;0
WireConnection;0;10;8;0
ASEEND*/
//CHKSM=32B889B4E81CFE3CEC89A8BAB9089A2A0BBFCCDA