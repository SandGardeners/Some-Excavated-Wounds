// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/MagusDynamicTesselation"
{
	Properties
	{
		_TexScale("TexScale", Float) = 1
		[Toggle(_LOCKSIZETOWORLD_ON)] _LockSizetoWorld("Lock Size to World", Float) = 0
		[HDR]_RimColor("Rim Color", Color) = (0,1,0.8758622,0)
		_RimPower("Rim Power", Range( 0 , 100)) = 0.5
		_RimOffset("Rim Offset", Float) = 0.24
		_MainColor("MainColor", Color) = (1,1,1,0)
		_Diffuse("Diffuse", 2D) = "white" {}
		_AlbedoLevel("AlbedoLevel", Range( 0 , 5)) = 1
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_DisplacementTex("DisplacementTex", 2D) = "white" {}
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Float) = 100
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_DeepShadeScale("DeepShadeScale", Float) = 0
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_DeepShadeOffset("DeepShadeOffset", Float) = 0
		_TesselationStrength("TesselationStrength", Range( 0 , 2)) = 0
		_ShadowOffset("ShadowOffset", Float) = -50
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		_TesselationSize("TesselationSize", Float) = 0
		[Toggle]_EnableTesselation("EnableTesselation", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		Stencil
		{
			Ref 0
		}
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma shader_feature _LOCKSIZETOWORLD_ON
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc tessellate:tessFunction 
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

		uniform sampler2D _DisplacementTex;
		uniform float _TesselationSize;
		uniform float _TesselationStrength;
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
		uniform float _EnableTesselation;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return lerp(UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 0.0,1.0,0.01),UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 50.0,200.0,5.0),_EnableTesselation);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _DisplacementTex, float4( ( ase_worldPos * _TesselationSize ).xy, 0, 1.0) ) / float4( ase_objectScale , 0.0 ) ) * float4( ase_vertexNormal , 0.0 ) * _TesselationStrength ).rgb;
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
			float lerpResult231 = lerp( 0.0 , lerpResult194 , ( 1.0 - temp_output_151_0 ));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi11 = gi;
			float3 diffNorm11 = ase_worldNormal;
			gi11 = UnityGI_Base( data, 1, diffNorm11 );
			float3 indirectDiffuse11 = gi11.indirect.diffuse + diffNorm11 * 0.0001;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult38 = dot( ase_worldNormal , ase_worldViewDir );
			c.rgb = ( ( ( tex2D( _Emission, uv_Emission ) * _EmissionColor ) + ( clampResult84 + ( ( ( tex2D( _Diffuse, uv_Diffuse ) * _MainColor ) * ( ( ase_lightColor * _AlbedoLevel * ( temp_output_151_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult231 ) ) + float4( indirectDiffuse11 , 0.0 ) ) ) * saturate( (ase_lightAtten*_DeepShadeScale + _DeepShadeOffset) ) ) ) ) + ( saturate( ( ( temp_output_151_0 * dotResult3 ) * pow( ( 1.0 - saturate( ( dotResult38 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) ).rgb;
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
1940;123;1886;1010;-2575.068;-1057.4;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;92;-3577.918,186.6267;Float;False;Property;_NormalScale;NormalScale;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-3083.118,113.1246;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;91;-3392.953,141.7988;Float;True;Property;_NormalMap;NormalMap;11;0;Create;True;0;0;False;0;None;42c12cb55ddd98245a0b2c96121c8a5a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;1;-2971.117,161.1245;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3019.117,321.1245;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-2496.471,-70.26369;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2446.471,186.9073;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2683.116,225.1245;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;168;-1711.836,-88.41492;Float;False;736.9673;335.4506;Comment;4;66;59;67;68;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2212.509,-14.2637;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1631.698,349.8171;Float;False;671.4778;278.8033;Comment;3;155;157;173;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;15;-1968.471,-28.17758;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1581.698,403.6204;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1641.013,132.0357;Float;False;Property;_ShadowOffset;ShadowOffset;23;0;Create;True;0;0;False;0;-50;-51.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1661.836,39.56157;Float;False;Property;_ShadowSharpness;ShadowSharpness;20;0;Create;True;0;0;False;0;100;98.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1401.144,-38.24265;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1354.979,403.7171;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1129.839,392.7536;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-1133.563,-26.30166;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-796.7751,-84.30011;Float;False;285;303;Comment;1;141;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-746.7751,-34.30014;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;-1623.671,1325.591;Float;False;ScreenspaceUV;0;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;151;-531.6902,-28.90755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1074.633,1218.692;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;25;0;Create;True;0;0;False;0;0;0.221;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;-1492.34,697.8774;Float;False;540.2805;466.2345;Comment;3;57;100;99;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;1324.259,840.2087;Float;False;507.201;385.7996;Comment;3;36;37;38;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;190;-1098.233,1325.09;Float;True;Property;_ShadeTex;ShadeTex;24;0;Create;True;0;0;False;0;None;c164bae765f280a4985a2f436103b626;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;50;1886.406,821.9999;Float;False;1617.938;553.8222;;14;33;46;32;31;34;47;35;30;29;28;27;25;24;7;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;230;-450.5214,1323.225;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;1420.259,1048.208;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;194;-539.3695,1183.672;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-1410.6,957.1122;Float;False;Property;_ShadowColor;ShadowColor;18;0;Create;True;0;0;False;0;0,0,0,0;0.2641508,0.230509,0.230509,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-1442.341,747.8774;Float;True;Property;_ShadowMap;ShadowMap;17;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;36;1372.259,888.2084;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;181;865.1548,-1110.3;Float;False;1381.51;553.5251;Comment;9;84;82;180;83;79;179;76;77;78;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1116.401,896.8563;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;231;-188.0474,1266.879;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;170;-48.5224,651.8431;Float;False;285;303;Comment;1;75;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;77;915.1548,-869.0199;Float;False;Property;_HighlightSharpness;HighlightSharpness;15;0;Create;True;0;0;False;0;100;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;945.7184,-779.5408;Float;False;Property;_HighlightOffset;HighlightOffset;16;0;Create;True;0;0;False;0;-80;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;136.4948,44.19838;Float;False;606.4951;329.9142;Comment;2;10;8;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;38;1676.259,968.2081;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;1966.407,1094.001;Float;False;Property;_RimOffset;Rim Offset;5;0;Create;True;0;0;False;0;0.24;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;1.477381,705.8797;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;115;1187.071,-394.7511;Float;False;649.3216;496.598;Comment;4;73;43;74;42;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;8;327.0912,102.1983;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;87;132.0846,227.2769;Float;False;Property;_AlbedoLevel;AlbedoLevel;8;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;2174.408,982.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;1187.049,-985.1174;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;1199.589,-110.9206;Float;False;Property;_MainColor;MainColor;6;0;Create;True;0;0;False;0;1,1,1,0;0.3989999,0.3314304,0.2928659,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;179;1389.738,-711.3754;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;27;2334.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;225;1488.665,389.0381;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;564.3023,122.5935;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;79;1453.825,-897.3636;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;1499.245,592.2324;Float;False;Property;_DeepShadeOffset;DeepShadeOffset;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;1540.844,498.6327;Float;False;Property;_DeepShadeScale;DeepShadeScale;19;0;Create;True;0;0;False;0;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;11;718.8511,467.1364;Float;True;Tangent;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;43;1205.893,-347.6611;Float;True;Property;_Diffuse;Diffuse;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;1659.127,-1060.3;Float;False;Property;_HighlightColor;HighlightColor;14;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;0.235294,0.1450979,0.1098038,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;1603.548,-872.7587;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;228;1854.144,492.1323;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;1112.074,185.3251;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;29;2510.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;2398.407,1110.001;Float;False;Property;_RimPower;Rim Power;4;0;Create;True;0;0;False;0;0.5;100;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;1493.794,-336.1253;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;213;2326.367,1420.888;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;229;2196.044,510.3323;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;116;2601.463,-276.3075;Float;False;550.4966;547.1101;Emission;3;94;96;97;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;211;2330.874,1633.214;Float;False;Property;_TesselationSize;TesselationSize;26;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1922.558,-882.899;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1609.898,-227.5557;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;2686.408,869.9999;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;2702.407,982.001;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;84;2071.665,-877.1222;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;34;2862.407,1094.001;Float;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;96;2654.686,66.90757;Float;False;Property;_EmissionColor;EmissionColor;10;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2942.408,950.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;2365.823,380.7787;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;2628.604,1537.222;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;94;2651.463,-226.3076;Float;True;Property;_Emission;Emission;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;47;2974.407,1270.001;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2681.721,391.3607;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;32;3134.408,950.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;164;3220.305,332.6938;Float;False;285;303;Blend Emission;1;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectScaleNode;210;2687.771,1815.906;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;2982.959,137.8024;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;237;3511.426,1474.576;Float;False;Constant;_Float1;Float 1;27;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;215;2789.244,1511.509;Float;True;Property;_DisplacementTex;DisplacementTex;13;0;Create;True;0;0;False;0;9789d23040cb1fb45ad60392430c3c15;b6f5ef030b0a64a409fcdb7b9224e095;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;3166.408,1078.001;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;212;3181.13,1654.314;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;221;3027.411,2048.846;Float;False;Property;_TesselationStrength;TesselationStrength;22;0;Create;True;0;0;False;0;0;1.11;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;232;3767.024,1400.538;Float;False;3;0;FLOAT;0;False;1;FLOAT;50;False;2;FLOAT;200;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;216;3048.294,1853.796;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceBasedTessNode;239;3586.885,1212.79;Float;False;3;0;FLOAT;0.01;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;123;3588.704,765.1691;Float;False;204;183;Blend Rim Light;1;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;3326.407,950.001;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3270.305,382.6937;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;3638.704,815.1692;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;224;1855.205,240.6627;Float;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;238;3946.401,1264.789;Float;False;Property;_EnableTesselation;EnableTesselation;27;0;Create;True;0;0;False;0;1;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;3434.857,2016.718;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;7;2457.145,871.4141;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4236.607,1085.171;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/MagusDynamicTesselation;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;True;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;17.7;10;50;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0.05;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;91;5;92;0
WireConnection;1;0;91;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;15;0;4;0
WireConnection;66;0;15;0
WireConnection;66;1;59;0
WireConnection;66;2;67;0
WireConnection;157;0;155;0
WireConnection;157;1;59;0
WireConnection;157;2;67;0
WireConnection;173;0;157;0
WireConnection;68;0;66;0
WireConnection;141;0;173;0
WireConnection;141;1;68;0
WireConnection;151;0;141;0
WireConnection;190;1;199;0
WireConnection;230;0;151;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;100;0;99;0
WireConnection;100;1;57;0
WireConnection;231;1;194;0
WireConnection;231;2;230;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;75;0;151;0
WireConnection;75;1;100;0
WireConnection;75;2;231;0
WireConnection;25;0;38;0
WireConnection;25;1;24;0
WireConnection;76;0;15;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;179;0;151;0
WireConnection;27;0;25;0
WireConnection;10;0;8;0
WireConnection;10;1;87;0
WireConnection;10;2;75;0
WireConnection;79;0;76;0
WireConnection;180;0;79;0
WireConnection;180;1;179;0
WireConnection;228;0;225;0
WireConnection;228;1;226;0
WireConnection;228;2;227;0
WireConnection;222;0;10;0
WireConnection;222;1;11;0
WireConnection;29;0;27;0
WireConnection;74;0;43;0
WireConnection;74;1;73;0
WireConnection;229;0;228;0
WireConnection;82;0;83;0
WireConnection;82;1;180;0
WireConnection;42;0;74;0
WireConnection;42;1;222;0
WireConnection;35;0;151;0
WireConnection;35;1;3;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;84;0;82;0
WireConnection;31;0;35;0
WireConnection;31;1;30;0
WireConnection;223;0;42;0
WireConnection;223;1;229;0
WireConnection;214;0;213;0
WireConnection;214;1;211;0
WireConnection;85;0;84;0
WireConnection;85;1;223;0
WireConnection;32;0;31;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;215;1;214;0
WireConnection;46;0;34;0
WireConnection;46;1;47;0
WireConnection;212;0;215;0
WireConnection;212;1;210;0
WireConnection;232;0;237;0
WireConnection;33;0;32;0
WireConnection;33;1;46;0
WireConnection;98;0;97;0
WireConnection;98;1;85;0
WireConnection;39;0;98;0
WireConnection;39;1;33;0
WireConnection;224;0;225;0
WireConnection;238;0;239;0
WireConnection;238;1;232;0
WireConnection;220;0;212;0
WireConnection;220;1;216;0
WireConnection;220;2;221;0
WireConnection;0;13;39;0
WireConnection;0;11;220;0
WireConnection;0;14;238;0
ASEEND*/
//CHKSM=B05C3DA857132B587E04EF5413658EE9BAACAA4F