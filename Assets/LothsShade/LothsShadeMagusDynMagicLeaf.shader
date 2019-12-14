// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/MagicLeaves"
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
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Range( 0 , 200)) = 100
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_ShadowOffset("ShadowOffset", Float) = -50
		_LightmapOffset("LightmapOffset", Float) = -50
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		_DeepShadeScale("DeepShadeScale", Float) = 0
		[Toggle(_USELIGHTMAPS_ON)] _UseLightmaps("Use Lightmaps", Float) = 0
		_BottomBlendColor("BottomBlendColor", Color) = (0,0,0,0)
		_LightmapSharpness("LightmapSharpness", Float) = 0
		_AltColorOne("AltColorOne", Color) = (0,0,0,0)
		_AltColorTwo("AltColorTwo", Color) = (0,0,0,0)
		_BottomBlendStrength("BottomBlendStrength", Range( 0 , 1)) = 0
		_DeepShadeOffset("DeepShadeOffset", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _USELIGHTMAPS_ON
		#pragma shader_feature _LOCKSIZETOWORLD_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
			float2 vertexToFrag10_g1;
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

		uniform float4 _HighlightColor;
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _HighlightSharpness;
		uniform float _HighlightOffset;
		// uniform sampler2D unity_Lightmap;
		uniform float _LightmapSharpness;
		uniform float _LightmapOffset;
		uniform float _ShadowSharpness;
		uniform float _ShadowOffset;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float4 _MainColor;
		uniform float4 _AltColorOne;
		uniform float4 _AltColorTwo;
		uniform float4 _BottomBlendColor;
		uniform float _BottomBlendStrength;
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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.vertexToFrag10_g1 = ( ( v.texcoord1.xy * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
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
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale ) )) , ase_worldlightDir );
			float temp_output_15_0 = saturate( (dotResult3*0.5 + 0.5) );
			float4 tex2DNode7_g1 = UNITY_SAMPLE_TEX2D( unity_Lightmap, i.vertexToFrag10_g1 );
			float3 decodeLightMap6_g1 = DecodeLightmap(tex2DNode7_g1);
			float grayscale146 = Luminance(decodeLightMap6_g1);
			#ifdef _USELIGHTMAPS_ON
				float staticSwitch208 = (saturate( (grayscale146*0.5 + 0.5) )*_LightmapSharpness + _LightmapOffset);
			#else
				float staticSwitch208 = 1.0;
			#endif
			float temp_output_68_0 = saturate( (temp_output_15_0*_ShadowSharpness + _ShadowOffset) );
			float temp_output_173_0 = saturate( (ase_lightAtten*_ShadowSharpness + _ShadowOffset) );
			float temp_output_151_0 = saturate( ( staticSwitch208 * temp_output_68_0 * temp_output_173_0 ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi237 = gi;
			float3 diffNorm237 = ase_worldNormal;
			gi237 = UnityGI_Base( data, 1, diffNorm237 );
			float3 indirectDiffuse237 = gi237.indirect.diffuse + diffNorm237 * 0.0001;
			float4 clampResult84 = clamp( ( _HighlightColor * ( saturate( (temp_output_15_0*_HighlightSharpness + _HighlightOffset) ) - ( 1.0 - temp_output_151_0 ) ) * ase_lightColor * float4( indirectDiffuse237 , 0.0 ) ) , float4( 0,0,0,0 ) , float4( 0.5,0.5,0.5,0 ) );
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float3 objToWorld250 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float fmodResult254 = frac(( objToWorld250.x + objToWorld250.y + objToWorld250.z )/3.0)*3.0;
			float temp_output_261_0 = floor( fmodResult254 );
			float4 lerpResult257 = lerp( _MainColor , _AltColorOne , temp_output_261_0);
			float4 lerpResult260 = lerp( lerpResult257 , _AltColorTwo , saturate( ( temp_output_261_0 - 1.0 ) ));
			float4 lerpResult240 = lerp( lerpResult260 , _BottomBlendColor , ( ( 1.0 - i.uv_texcoord.y ) * _BottomBlendStrength ));
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
			float lerpResult234 = lerp( 0.0 , lerpResult194 , ( 1.0 - temp_output_151_0 ));
			UnityGI gi11 = gi;
			float3 diffNorm11 = ase_worldNormal;
			gi11 = UnityGI_Base( data, 1, diffNorm11 );
			float3 indirectDiffuse11 = gi11.indirect.diffuse + diffNorm11 * 0.0001;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult38 = dot( ase_worldNormal , ase_worldViewDir );
			c.rgb = ( ( clampResult84 + ( ( ( tex2D( _Diffuse, uv_Diffuse ) * lerpResult240 ) * ( ( ase_lightColor * _AlbedoLevel * saturate( ( temp_output_151_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult234 ) ) ) + float4( indirectDiffuse11 , 0.0 ) ) ) * saturate( (ase_lightAtten*_DeepShadeScale + _DeepShadeOffset) ) ) ) + ( saturate( ( ( ase_lightAtten * dotResult3 ) * pow( ( 1.0 - saturate( ( dotResult38 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) ).rgb;
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
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.vertexToFrag10_g1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.vertexToFrag10_g1 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16702
1940;123;1886;1010;419.1305;2642.467;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;92;-3471.219,107.2229;Float;False;Property;_NormalScale;NormalScale;12;0;Create;True;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-3286.254,62.39502;Float;True;Property;_NormalMap;NormalMap;11;0;Create;True;0;0;False;0;None;c3fc283aa0eb2ac4dbf2e234343bb6a5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;48;-2983.863,43.64631;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;166;-2182.831,-548.4812;Float;False;1249.509;344.2948;Stylize Lightmaos;8;146;149;148;147;140;144;142;138;Stylize Lightmaps;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;138;-2111.3,-471.6589;Float;False;FetchLightmapValue;3;;1;43de3d4ae59f645418fdd020d1b8e78e;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-2871.862,91.64619;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-2920.942,251.6463;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-2355.033,-95.07737;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2583.861,155.6462;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;146;-1861.172,-472.0588;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2282.033,99.09362;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-1817.437,-396.5448;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1394.646,294.8329;Float;False;671.4778;278.8033;Comment;3;155;157;173;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2033.071,-45.07738;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;148;-1662.676,-472.9443;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;168;-1478.588,-95.85902;Float;False;736.9673;335.4506;Comment;4;66;59;67;68;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-1443.891,-319.1866;Float;False;Property;_LightmapOffset;LightmapOffset;20;0;Create;True;0;0;False;0;-50;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1368.646,338.6361;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1437.757,-410.4154;Float;False;Property;_LightmapSharpness;LightmapSharpness;26;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;147;-1424.027,-498.4814;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1439.764,130.5916;Float;False;Property;_ShadowOffset;ShadowOffset;19;0;Create;True;0;0;False;0;-50;-15.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1450.588,39.11746;Float;False;Property;_ShadowSharpness;ShadowSharpness;18;0;Create;True;0;0;False;0;100;31.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1833.433,-41.79126;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1119.227,351.3329;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;142;-1164.321,-449.7258;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1167.896,-45.68676;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-1032.145,-758.9236;Float;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-918.129,-44.7554;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-439.342,-108.798;Float;False;443.2562;289.4352;Comment;2;151;141;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;224;-752.935,1220.141;Float;False;830.347;382.0016;Shadow texture;4;194;190;193;199;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;173;-917.6627,335.1649;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;208;-795.3636,-399.4432;Float;False;Property;_UseLightmaps;Use Lightmaps;24;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;250;167.3871,-2035.456;Float;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;252;397.8124,-2002.088;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-389.342,-58.79804;Float;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;-702.935,1304.301;Float;False;ScreenspaceUV;0;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;255;334.8518,-1842.76;Float;False;Constant;_NumberOfColors;NumberOfColors;27;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimplifiedFModOpNode;254;542.6742,-1921.321;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;-1068.026,673.6357;Float;False;540.2805;466.2345;Comment;3;57;100;99;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;151;-185.2856,14.92512;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-464.6521,1487.143;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;22;0;Create;True;0;0;False;0;0;0.179;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;190;-479.4515,1270.141;Float;True;Property;_ShadeTex;ShadeTex;21;0;Create;True;0;0;False;0;None;c164bae765f280a4985a2f436103b626;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;49;1323.506,1311.75;Float;False;507.201;385.7996;Comment;3;36;37;38;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;263;779.1166,-1793.352;Float;False;Constant;_Float3;Float 3;27;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;261;755.063,-1918.55;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;1419.506,1519.749;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;36;1371.506,1359.75;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;50;1918.687,1312.78;Float;False;1617.938;553.8222;;14;33;46;32;31;34;47;35;30;29;28;27;25;24;7;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;57;-986.2858,932.8705;Float;False;Property;_ShadowColor;ShadowColor;17;0;Create;True;0;0;False;0;0,0,0,0;0.8103132,0.6018156,0.8679245,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;233;186.0529,1157.648;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;194;-106.5882,1282.723;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;99;-1018.027,723.6357;Float;True;Property;_ShadowMap;ShadowMap;16;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;181;1063.178,-635.6888;Float;False;1381.51;553.5251;Comment;11;84;82;180;83;79;179;76;77;78;236;237;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;170;174.2106,286.3578;Float;False;285;303;Comment;1;75;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-692.0867,872.6146;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;239;1210.706,500.9455;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;38;1675.506,1439.75;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;234;415.5268,1169.302;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;262;940.4015,-1875.612;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;248;777.1956,-2111.072;Float;False;Property;_AltColorOne;AltColorOne;27;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;73;772.6666,-2294.663;Float;False;Property;_MainColor;MainColor;8;0;Create;True;0;0;False;0;1,1,1,0;1,0.514151,0.6547914,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;1998.688,1584.781;Float;False;Property;_RimOffset;Rim Offset;7;0;Create;True;0;0;False;0;0.24;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;244;1517.662,568.2397;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;264;1095.49,-1876.813;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;257;1085.446,-2119.012;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;249;1086.396,-2333.771;Float;False;Property;_AltColorTwo;AltColorTwo;28;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;1113.178,-394.4084;Float;False;Property;_HighlightSharpness;HighlightSharpness;14;0;Create;True;0;0;False;0;100;1;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1143.741,-304.9294;Float;False;Property;_HighlightOffset;HighlightOffset;15;0;Create;True;0;0;False;0;-80;-0.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;224.2103,340.3943;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;242;1171.347,143.6345;Float;False;Property;_BottomBlendStrength;BottomBlendStrength;29;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;2206.688,1472.781;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;476.5948,177.1983;Float;False;606.4951;329.9142;Light colour;3;10;8;87;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;27;2366.687,1472.781;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;223;1418.626,854.2711;Float;False;524.3274;303;Add indirect lighting;2;219;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;87;517.9713,413.8177;Float;False;Property;_AlbedoLevel;AlbedoLevel;10;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;115;1704.841,84.37717;Float;False;649.3216;496.598;Comment;4;43;74;42;240;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;241;1717.075,620.2284;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;1385.072,-510.506;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;238;1396.516,314.888;Float;False;Property;_BottomBlendColor;BottomBlendColor;25;0;Create;True;0;0;False;0;0,0,0,0;0.8962264,0.6214399,0.7009834,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;260;1349.942,-2024.338;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;235;600.5318,648.8433;Float;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;8;591.1915,207.1983;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;179;1637.557,-289.1781;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;11;1468.626,981.7755;Float;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;2430.687,1600.781;Float;False;Property;_RimPower;Rim Power;6;0;Create;True;0;0;False;0;0.5;7.4;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;849.7687,242.2935;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;240;1903.565,395.8262;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;43;1720.463,131.8671;Float;True;Property;_Diffuse;Diffuse;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;230;2041.509,924.2781;Float;False;Property;_DeepShadeScale;DeepShadeScale;23;0;Create;True;0;0;False;0;0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;79;1685.848,-433.7521;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;2071.548,1007.928;Float;False;Property;_DeepShadeOffset;DeepShadeOffset;30;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;7;2351.084,1367.456;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;226;2041.337,839.6975;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;2542.687,1472.781;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;237;1821.136,-168.7692;Float;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;236;1658.526,-604.1124;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;219;1720.753,921.8714;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;1860.571,-391.1473;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;2718.688,1360.78;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;231;2284.065,840.8048;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;1857.15,-585.6887;Float;False;Property;_HighlightColor;HighlightColor;13;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;0.9150943,0.5730212,0.5481932,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;2025.484,225.0472;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;30;2734.687,1472.781;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;2107.581,-413.2875;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2974.688,1440.781;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;47;3006.687,1760.781;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;34;2894.687,1584.781;Float;False;Property;_RimColor;Rim Color;5;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0.05767177,0.1455247,0.1509434,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;232;2556.849,928.0911;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;2149.667,350.7726;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;220;2893.1,456.7122;Float;False;285;303;Blend Highlights;1;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;84;2231.988,-412.9107;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;32;3166.688,1440.781;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;2726.419,830.8685;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;3198.688,1568.781;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2943.1,506.7122;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;123;3588.704,765.1691;Float;False;204;183;Blend Rim Light;1;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;225;-651.0179,254.2955;Float;False;234;306.1558;Alternate blend modes;2;214;210;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;3343.477,1422.192;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;259;733.1536,-1239.946;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;214;-601.0179,404.4512;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;210;-582.5022,304.2955;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;3621.104,778.3692;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;247;3695.825,394.6995;Float;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;False;0;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4497.727,440.5369;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/MagicLeaves;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;99999;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;7;False;-1;2;False;-1;2;False;-1;2;False;-1;7;False;-1;2;False;-1;2;False;-1;2;False;-1;False;0;4;6.95;23.32;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0.05;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;True;0;0;False;-1;-1;0;True;249;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;91;5;92;0
WireConnection;1;0;91;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;146;0;138;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;148;0;146;0
WireConnection;148;1;149;0
WireConnection;148;2;149;0
WireConnection;147;0;148;0
WireConnection;15;0;4;0
WireConnection;157;0;155;0
WireConnection;157;1;59;0
WireConnection;157;2;67;0
WireConnection;142;0;147;0
WireConnection;142;1;140;0
WireConnection;142;2;144;0
WireConnection;66;0;15;0
WireConnection;66;1;59;0
WireConnection;66;2;67;0
WireConnection;68;0;66;0
WireConnection;173;0;157;0
WireConnection;208;1;209;0
WireConnection;208;0;142;0
WireConnection;252;0;250;1
WireConnection;252;1;250;2
WireConnection;252;2;250;3
WireConnection;141;0;208;0
WireConnection;141;1;68;0
WireConnection;141;2;173;0
WireConnection;254;0;252;0
WireConnection;254;1;255;0
WireConnection;151;0;141;0
WireConnection;190;1;199;0
WireConnection;261;0;254;0
WireConnection;233;0;151;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;100;0;99;0
WireConnection;100;1;57;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;234;1;194;0
WireConnection;234;2;233;0
WireConnection;262;0;261;0
WireConnection;262;1;263;0
WireConnection;244;0;239;2
WireConnection;264;0;262;0
WireConnection;257;0;73;0
WireConnection;257;1;248;0
WireConnection;257;2;261;0
WireConnection;75;0;151;0
WireConnection;75;1;100;0
WireConnection;75;2;234;0
WireConnection;25;0;38;0
WireConnection;25;1;24;0
WireConnection;27;0;25;0
WireConnection;241;0;244;0
WireConnection;241;1;242;0
WireConnection;76;0;15;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;260;0;257;0
WireConnection;260;1;249;0
WireConnection;260;2;264;0
WireConnection;235;0;75;0
WireConnection;179;0;151;0
WireConnection;10;0;8;0
WireConnection;10;1;87;0
WireConnection;10;2;235;0
WireConnection;240;0;260;0
WireConnection;240;1;238;0
WireConnection;240;2;241;0
WireConnection;79;0;76;0
WireConnection;29;0;27;0
WireConnection;219;0;10;0
WireConnection;219;1;11;0
WireConnection;180;0;79;0
WireConnection;180;1;179;0
WireConnection;35;0;7;0
WireConnection;35;1;3;0
WireConnection;231;0;226;0
WireConnection;231;1;230;0
WireConnection;231;2;229;0
WireConnection;74;0;43;0
WireConnection;74;1;240;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;82;0;83;0
WireConnection;82;1;180;0
WireConnection;82;2;236;0
WireConnection;82;3;237;0
WireConnection;31;0;35;0
WireConnection;31;1;30;0
WireConnection;232;0;231;0
WireConnection;42;0;74;0
WireConnection;42;1;219;0
WireConnection;84;0;82;0
WireConnection;32;0;31;0
WireConnection;228;0;42;0
WireConnection;228;1;232;0
WireConnection;46;0;34;0
WireConnection;46;1;47;0
WireConnection;85;0;84;0
WireConnection;85;1;228;0
WireConnection;33;0;32;0
WireConnection;33;1;46;0
WireConnection;214;0;68;0
WireConnection;214;1;173;0
WireConnection;214;2;5;0
WireConnection;210;0;68;0
WireConnection;210;1;173;0
WireConnection;39;0;85;0
WireConnection;39;1;33;0
WireConnection;0;13;39;0
ASEEND*/
//CHKSM=470DC4D7FAEC76832EF2E0079BB7CC96A01510B3