// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/Cloud"
{
	Properties
	{
		_CurveMultiplier("CurveMultiplier", Float) = 0
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 40.7
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.625
		_TexScale("TexScale", Float) = 1
		[Toggle(_LOCKSIZETOWORLD_ON)] _LockSizetoWorld("Lock Size to World", Float) = 0
		[HDR]_RimColor("Rim Color", Color) = (0,1,0.8758622,0)
		_RimPower("Rim Power", Float) = 0.5
		_RimOffset("Rim Offset", Float) = 0.24
		_MainColor("MainColor", Color) = (1,1,1,0)
		_DisplacementTex("DisplacementTex", 2D) = "white" {}
		_Diffuse("Diffuse", 2D) = "white" {}
		_DeepShadeScale("DeepShadeScale", Float) = 0
		_AlbedoLevel("AlbedoLevel", Range( 0 , 5)) = 1
		_Emission("Emission", 2D) = "white" {}
		_DeepShadeOffset("DeepShadeOffset", Float) = 0
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Float) = 100
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_WeatherMeter("WeatherMeter", Range( 0 , 1)) = 0
		_GroundLevel("GroundLevel", Float) = 0
		_TesselationSize("TesselationSize", Float) = 0
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_DarkestColor("DarkestColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_ShadowOffset("ShadowOffset", Float) = -50
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Off
		Stencil
		{
			Ref 222
			ReadMask 0
			WriteMask 222
			PassFront Replace
			FailFront Replace
			ZFailFront Replace
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma shader_feature _LOCKSIZETOWORLD_ON
		#pragma addshadow
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _GroundLevel;
		uniform float _CurveMultiplier;
		uniform sampler2D _DisplacementTex;
		uniform float _TesselationSize;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _EmissionColor;
		uniform float4 _HighlightColor;
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _HighlightSharpness;
		uniform float _HighlightOffset;
		uniform float _ShadowSharpness;
		uniform float _ShadowOffset;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float4 _MainColor;
		uniform float4 _DarkestColor;
		uniform float _WeatherMeter;
		uniform float _AlbedoLevel;
		uniform sampler2D _ShadowMap;
		uniform float4 _ShadowMap_ST;
		uniform float4 _ShadowColor;
		uniform sampler2D _ShadeTex;
		uniform float _TexScale;
		uniform float _ShadeTexIntensity;
		uniform float _DeepShadeScale;
		uniform float _DeepShadeOffset;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _EdgeLength;
		uniform float _TessPhongStrength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 appendResult25_g50 = (float3(ase_vertex3Pos.x , ( ase_vertex3Pos.y + _GroundLevel ) , ase_vertex3Pos.z));
			float4 transform11_g50 = mul(unity_ObjectToWorld,float4( appendResult25_g50 , 0.0 ));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult14_g50 = (float4(ase_worldPos.x , ase_worldPos.y , ase_worldPos.z , 0.0));
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float4 transform13_g50 = mul(unity_WorldToObject,( transform11_g50 + float4( ( pow( distance( appendResult14_g50 , float4( float3(0,0,0) , 0.0 ) ) , 2.0 ) * ( _CurveMultiplier * ase_objectScale ) * float3(0,1,0) ) , 0.0 ) ));
			float4 transform305 = mul(unity_WorldToObject,transform13_g50);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( transform305 + float4( ( tex2Dlod( _DisplacementTex, float4( ( ase_worldPos * _TesselationSize ).xy, 0, 1.0) ).r * ase_vertexNormal ) , 0.0 ) ).xyz;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale ) )) , ase_worldlightDir );
			float temp_output_15_0 = saturate( (dotResult3*0.5 + 0.5) );
			float temp_output_151_0 = saturate( ( saturate( (ase_lightAtten*_ShadowSharpness + _ShadowOffset) ) * saturate( (temp_output_15_0*_ShadowSharpness + _ShadowOffset) ) ) );
			float4 clampResult84 = clamp( ( _HighlightColor * ( saturate( (temp_output_15_0*_HighlightSharpness + _HighlightOffset) ) - ( 1.0 - temp_output_151_0 ) ) ) , float4( 0,0,0,0 ) , float4( 0.5,0.5,0.5,0 ) );
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 color285 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float clampResult287 = clamp( _WeatherMeter , 0.5 , 1.0 );
			float4 lerpResult281 = lerp( color285 , _DarkestColor , clampResult287);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_ShadowMap = i.uv_texcoord * _ShadowMap_ST.xy + _ShadowMap_ST.zw;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos16_g7 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 computeScreenPos14_g7 = ComputeScreenPos( unityObjectToClipPos16_g7 );
			float4 unityObjectToClipPos17_g7 = UnityObjectToClipPos( float3(0,0,0) );
			float4 computeScreenPos15_g7 = ComputeScreenPos( unityObjectToClipPos17_g7 );
			float4 transform6_g7 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			#ifdef _LOCKSIZETOWORLD_ON
				float staticSwitch22_g7 = distance( ( float4( _WorldSpaceCameraPos , 0.0 ) - transform6_g7 ) , float4( 0,0,0,0 ) );
			#else
				float staticSwitch22_g7 = 1.0;
			#endif
			float lerpResult194 = lerp( 0.0 , tex2D( _ShadeTex, ( ( ( ( computeScreenPos14_g7 / (computeScreenPos14_g7).w ) * _TexScale ) - ( ( computeScreenPos15_g7 / (computeScreenPos15_g7).w ) * _TexScale ) ) * staticSwitch22_g7 ).xy ).a , _ShadeTexIntensity);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi11 = gi;
			float3 diffNorm11 = ase_worldNormal;
			gi11 = UnityGI_Base( data, 1, diffNorm11 );
			float3 indirectDiffuse11 = gi11.indirect.diffuse + diffNorm11 * 0.0001;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult38 = dot( ase_worldNormal , ase_worldViewDir );
			float4 temp_output_39_0 = ( ( ( tex2D( _Emission, uv_Emission ) * _EmissionColor ) + ( clampResult84 + ( ( ( tex2D( _Diffuse, uv_Diffuse ) * _MainColor * lerpResult281 ) * ( ( ase_lightColor * _AlbedoLevel * saturate( ( temp_output_151_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult194 ) ) ) + float4( indirectDiffuse11 , 0.0 ) ) ) * saturate( (ase_lightAtten*_DeepShadeScale + _DeepShadeOffset) ) ) ) ) + ( saturate( ( ( temp_output_151_0 * dotResult3 ) * pow( ( 1.0 - saturate( ( dotResult38 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) );
			c.rgb = temp_output_39_0.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16702
13;11;1906;1010;-1629.296;-941.8014;1.466937;True;False
Node;AmplifyShaderEditor.RangedFloatNode;92;-3577.918,186.6267;Float;False;Property;_NormalScale;NormalScale;28;0;Create;True;0;0;False;0;1;1.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-3392.953,141.7988;Float;True;Property;_NormalMap;NormalMap;27;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;1;-2971.117,161.1245;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3019.117,321.1245;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-2418.625,124.5847;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2683.116,225.1245;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2174.509,-20.2637;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1602.836,382.4823;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1661.836,39.56157;Float;False;Property;_ShadowSharpness;ShadowSharpness;38;0;Create;True;0;0;False;0;100;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1968.471,-28.17758;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1641.013,132.0357;Float;False;Property;_ShadowOffset;ShadowOffset;39;0;Create;True;0;0;False;0;-50;-17.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1357.917,378.679;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1401.144,-38.24265;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;-1623.671,1325.591;Float;False;ScreenspaceUV;8;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;68;-1149.869,-38.41495;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1156.358,383.3756;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;99;-1442.341,747.8774;Float;True;Property;_ShadowMap;ShadowMap;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-746.7751,-34.30014;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;190;-1098.233,1325.09;Float;True;Property;_ShadeTex;ShadeTex;40;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;-1410.6,957.1122;Float;False;Property;_ShadowColor;ShadowColor;36;0;Create;True;0;0;False;0;0,0,0,0;0.9386792,0.9693395,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-1074.633,1218.692;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;41;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;-531.6902,-28.90755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;1420.259,1048.208;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;36;1372.259,888.2084;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;194;-560.3695,1095.672;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1116.401,896.8563;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;38;1676.259,968.2081;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;286;337.7852,-309.5467;Float;False;Property;_WeatherMeter;WeatherMeter;33;0;Create;True;0;0;False;0;0;0.3605572;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;3.2069,704.1502;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;78;945.7184,-779.5408;Float;False;Property;_HighlightOffset;HighlightOffset;31;0;Create;True;0;0;False;0;-80;-0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;915.1548,-869.0199;Float;False;Property;_HighlightSharpness;HighlightSharpness;30;0;Create;True;0;0;False;0;100;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;1966.407,1094.001;Float;False;Property;_RimOffset;Rim Offset;13;0;Create;True;0;0;False;0;0.24;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;287;727.7848,-340.7459;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;189;303.0161,791.6942;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;8;328.0912,102.1983;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;285;599.0851,-676.1459;Float;False;Constant;_White;White;29;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;1187.049,-985.1174;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;288;348.1848,-535.7462;Float;False;Property;_DarkestColor;DarkestColor;37;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;2174.408,982.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;78.1535,468.8882;Float;False;Property;_AlbedoLevel;AlbedoLevel;21;0;Create;True;0;0;False;0;1;0.42;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;1205.893,-347.6611;Float;True;Property;_Diffuse;Diffuse;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;79;1453.825,-897.3636;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;313;1381.636,530.002;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;115;1187.071,-394.7511;Float;False;649.3216;496.598;Comment;2;42;74;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;179;1438.546,-803.7609;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;27;2334.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;1372.708,605.4832;Float;False;Property;_DeepShadeScale;DeepShadeScale;20;0;Create;True;0;0;False;0;0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;281;1021.584,-494.1464;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;73;1199.589,-110.9206;Float;False;Property;_MainColor;MainColor;17;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;11;1049.042,217.3786;Float;False;Tangent;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;311;1375.447,691.7332;Float;False;Property;_DeepShadeOffset;DeepShadeOffset;25;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;560.9684,122.5935;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;314;1594.464,555.8102;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;1445.752,275.1138;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;1501.114,-129.8811;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;1603.548,-872.7587;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;2510.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;1659.127,-1060.3;Float;False;Property;_HighlightColor;HighlightColor;29;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;0.6320754,0.6320754,0.6320754,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;2398.407,1110.001;Float;False;Property;_RimPower;Rim Power;12;0;Create;True;0;0;False;0;0.5;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;50;1886.406,821.9999;Float;False;1617.938;553.8222;;1;35;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1639.898,-131.5557;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;315;1826.248,554.0961;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;2387.617,1752.998;Float;False;Property;_TesselationSize;TesselationSize;35;0;Create;True;0;0;False;0;0;0.001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;267;2405.386,1553.75;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;2686.408,869.9999;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;2702.407,982.001;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1922.558,-882.899;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;2651.463,-226.3076;Float;True;Property;_Emission;Emission;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;84;2071.665,-877.1222;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;1987.429,221.1521;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;47;2974.407,1270.001;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;34;2862.407,1094.001;Float;False;Property;_RimColor;Rim Color;11;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0.1228954,0.1228954,0.1228954,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;96;2654.686,66.90757;Float;False;Property;_EmissionColor;EmissionColor;26;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;2828.297,1672.682;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;309;3312.011,1429.763;Float;False;Property;_GroundLevel;GroundLevel;34;0;Create;True;0;0;False;0;0;80;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2942.408,950.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;3134.408,950.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;2982.959,137.8024;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;3166.408,1078.001;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2402.73,388.6313;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;365;3707.948,1408.607;Float;False;CurveWorld;1;;50;e2e368e93df0263448665ee9ffe4a05c;0;1;16;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;164;3220.305,332.6938;Float;False;285;303;Blend Emission;1;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;263;3607.468,1916.508;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;253;2998.421,1608.815;Float;True;Property;_DisplacementTex;DisplacementTex;18;0;Create;True;0;0;False;0;9789d23040cb1fb45ad60392430c3c15;1999cf6bdc177c24e8d6a403f039d8ac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3270.305,382.6937;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;305;3941.74,1301.587;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;264;4049.268,1656.608;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;3326.407,950.001;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-155.7107,-1764.817;Float;False;Property;_TranslucencyScale;TranslucencyScale;15;0;Create;True;0;0;False;0;0.1;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;3325.355,-75.91563;Float;True;Property;_Opacity;Opacity;22;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;187;3624.592,-122.1869;Float;False;Property;_Alpha;Alpha;23;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;245;-556.1382,-1282.77;Float;False;Property;_TranslucencyColor;TranslucencyColor;14;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;39;3638.704,815.1692;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;244;-499.5239,-1415.824;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;250;356.2563,-1842.794;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;248;-498.6692,-1085.621;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;303;4349.299,1353.068;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LightAttenuation;7;2457.145,871.4141;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-215.8876,-1662.343;Float;False;Property;_TranslucencyOffset;TranslucencyOffset;16;0;Create;True;0;0;False;0;-0.09;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;249;104.9813,-1842.621;Float;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;4152.228,1036.821;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;3707.592,105.8131;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-309.6956,-1371.966;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;4102.103,462.6959;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectScaleNode;356;3954.75,1079.338;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;358;4329.935,1179.923;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4610.165,401.6421;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/Cloud;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;True;Off;0;False;-1;0;False;-1;False;10;False;-1;10;False;-1;False;2;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;True;222;False;-1;0;False;-1;222;False;-1;0;False;-1;3;False;-1;3;False;-1;3;False;-1;0;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;40.7;6.95;23.32;True;0.625;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;7.02;0,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;0;-1;-1;3;0;False;0;0;False;-1;-1;0;False;-1;1;Pragma;addshadow;False;;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1652.836,328.679;Float;False;671.4778;278.8033;Comment;0;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;116;2601.463,-276.3075;Float;False;550.4966;547.1101;Emission;0;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;170;-46.79288,650.1136;Float;False;285;303;Comment;0;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;136.4948,44.19838;Float;False;606.4951;329.9142;Comment;0;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;865.1548,-1110.3;Float;False;1381.51;553.5251;Comment;0;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;169;-1492.34,697.8774;Float;False;540.2805;466.2345;Comment;0;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;-796.7751,-84.30011;Float;False;285;303;Comment;0;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2496.471,-70.26369;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;0;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;123;3588.704,765.1691;Float;False;204;183;Blend Rim Light;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;1324.259,840.2087;Float;False;507.201;385.7996;Comment;0;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;168;-1711.836,-88.41492;Float;False;736.9673;335.4506;Comment;0;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-3083.118,113.1246;Float;False;540.401;320.6003;Comment;0;N . L;1,1,1,1;0;0
WireConnection;91;5;92;0
WireConnection;1;0;91;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;15;0;4;0
WireConnection;157;0;155;0
WireConnection;157;1;59;0
WireConnection;157;2;67;0
WireConnection;66;0;15;0
WireConnection;66;1;59;0
WireConnection;66;2;67;0
WireConnection;68;0;66;0
WireConnection;173;0;157;0
WireConnection;141;0;173;0
WireConnection;141;1;68;0
WireConnection;190;1;199;0
WireConnection;151;0;141;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;100;0;99;0
WireConnection;100;1;57;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;75;0;151;0
WireConnection;75;1;100;0
WireConnection;75;2;194;0
WireConnection;287;0;286;0
WireConnection;189;0;75;0
WireConnection;76;0;15;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;25;0;38;0
WireConnection;25;1;24;0
WireConnection;79;0;76;0
WireConnection;179;0;151;0
WireConnection;27;0;25;0
WireConnection;281;0;285;0
WireConnection;281;1;288;0
WireConnection;281;2;287;0
WireConnection;10;0;8;0
WireConnection;10;1;87;0
WireConnection;10;2;189;0
WireConnection;314;0;313;0
WireConnection;314;1;312;0
WireConnection;314;2;311;0
WireConnection;280;0;10;0
WireConnection;280;1;11;0
WireConnection;74;0;43;0
WireConnection;74;1;73;0
WireConnection;74;2;281;0
WireConnection;180;0;79;0
WireConnection;180;1;179;0
WireConnection;29;0;27;0
WireConnection;42;0;74;0
WireConnection;42;1;280;0
WireConnection;315;0;314;0
WireConnection;35;0;151;0
WireConnection;35;1;3;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;82;0;83;0
WireConnection;82;1;180;0
WireConnection;84;0;82;0
WireConnection;316;0;42;0
WireConnection;316;1;315;0
WireConnection;268;0;267;0
WireConnection;268;1;269;0
WireConnection;31;0;35;0
WireConnection;31;1;30;0
WireConnection;32;0;31;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;46;0;34;0
WireConnection;46;1;47;0
WireConnection;85;0;84;0
WireConnection;85;1;316;0
WireConnection;365;16;309;0
WireConnection;253;1;268;0
WireConnection;98;0;97;0
WireConnection;98;1;85;0
WireConnection;305;0;365;0
WireConnection;264;0;253;1
WireConnection;264;1;263;0
WireConnection;33;0;32;0
WireConnection;33;1;46;0
WireConnection;39;0;98;0
WireConnection;39;1;33;0
WireConnection;244;0;15;0
WireConnection;250;0;249;0
WireConnection;303;0;305;0
WireConnection;303;1;264;0
WireConnection;249;0;246;0
WireConnection;249;1;251;0
WireConnection;249;2;252;0
WireConnection;359;0;356;2
WireConnection;359;1;305;2
WireConnection;188;0;187;0
WireConnection;188;1;101;0
WireConnection;246;0;244;0
WireConnection;246;1;245;0
WireConnection;246;2;248;0
WireConnection;247;0;250;0
WireConnection;247;1;39;0
WireConnection;358;0;305;1
WireConnection;358;1;359;0
WireConnection;358;2;305;3
WireConnection;358;3;305;4
WireConnection;0;13;39;0
WireConnection;0;11;303;0
ASEEND*/
//CHKSM=7C86CB9AE9B42610C6CE947DF9D989757F78F9E3