// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/Moon"
{
	Properties
	{
		_TexScale("TexScale", Float) = 1
		[Toggle(_LOCKSIZETOWORLD_ON)] _LockSizetoWorld("Lock Size to World", Float) = 0
		_MainColor("MainColor", Color) = (1,1,1,0)
		_Diffuse("Diffuse", 2D) = "white" {}
		_AlbedoLevel("AlbedoLevel", Range( 0 , 5)) = 1
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Float) = 100
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_ShadowOffset("ShadowOffset", Float) = -50
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Offset  9999 , 0
		Blend OneMinusDstColor One
		BlendOp Add
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
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

		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
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
		uniform float4 _MainColor;
		uniform sampler2D _ShadowMap;
		uniform float4 _ShadowMap_ST;
		uniform float4 _ShadowColor;
		uniform sampler2D _ShadeTex;
		uniform float _TexScale;
		uniform float _ShadeTexIntensity;
		uniform float _AlbedoLevel;

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
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 tex2DNode43 = tex2D( _Diffuse, uv_Diffuse );
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
			float4 temp_output_98_0 = ( ( tex2D( _Emission, uv_Emission ) * _EmissionColor ) + ( clampResult84 + ( _MainColor * ( saturate( ( temp_output_151_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult194 ) ) * _AlbedoLevel ) ) ) );
			c.rgb = temp_output_98_0.rgb;
			c.a = ( tex2DNode43 * temp_output_98_0 ).r;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow exclude_path:deferred nolightmap  nodirlightmap 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16400
2247;1176;1504;1010;-2698.854;136.5349;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;92;-3577.918,186.6267;Float;False;Property;_NormalScale;NormalScale;10;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-3083.118,113.1246;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;91;-3392.953,141.7988;Float;True;Property;_NormalMap;NormalMap;9;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;1;-2971.117,161.1245;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3019.117,321.1245;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-2496.471,-70.26369;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2446.471,186.9073;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2683.116,225.1245;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;168;-1711.836,-88.41492;Float;False;736.9673;335.4506;Comment;4;66;59;67;68;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2174.509,-20.2637;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1631.698,349.8171;Float;False;671.4778;278.8033;Comment;3;155;157;173;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1581.698,403.6204;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1968.471,-28.17758;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1641.013,132.0357;Float;False;Property;_ShadowOffset;ShadowOffset;17;0;Create;True;0;0;False;0;-50;-54.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1661.836,39.56157;Float;False;Property;_ShadowSharpness;ShadowSharpness;16;0;Create;True;0;0;False;0;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1401.144,-38.24265;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1336.779,399.8171;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;-1492.34,697.8774;Float;False;540.2805;466.2345;Comment;3;57;100;99;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;68;-1149.869,-38.41495;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1135.22,404.5137;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-796.7751,-84.30011;Float;False;285;303;Comment;1;141;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;865.1548,-1110.3;Float;False;1381.51;553.5251;Comment;9;84;82;180;83;79;179;76;77;78;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;199;-1623.671,1325.591;Float;False;ScreenspaceUV;1;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-746.7751,-34.30014;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;945.7184,-779.5408;Float;False;Property;_HighlightOffset;HighlightOffset;13;0;Create;True;0;0;False;0;-80;-0.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;190;-1098.233,1325.09;Float;True;Property;_ShadeTex;ShadeTex;18;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-1442.341,747.8774;Float;True;Property;_ShadowMap;ShadowMap;14;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;-1410.6,957.1122;Float;False;Property;_ShadowColor;ShadowColor;15;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;915.1548,-869.0199;Float;False;Property;_HighlightSharpness;HighlightSharpness;12;0;Create;True;0;0;False;0;100;1.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1074.633,1218.692;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;194;-560.3695,1095.672;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;1187.049,-985.1174;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1116.401,896.8563;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;170;-46.79288,650.1136;Float;False;285;303;Comment;1;75;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;151;-531.6902,-28.90755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;79;1453.825,-897.3636;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;3.2069,704.1502;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;179;1438.546,-803.7609;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;136.4948,44.19838;Float;False;606.4951;329.9142;Comment;1;10;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;87;78.1535,468.8882;Float;False;Property;_AlbedoLevel;AlbedoLevel;6;0;Create;True;0;0;False;0;1;1.04;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;189;303.0161,791.6942;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;83;1659.127,-1060.3;Float;False;Property;_HighlightColor;HighlightColor;11;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;115;1142.271,-391.5512;Float;False;649.3216;496.598;Comment;4;73;74;42;43;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;1603.548,-872.7587;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;560.9684,122.5935;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1922.558,-882.899;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;73;1154.789,-107.7206;Float;False;Property;_MainColor;MainColor;4;0;Create;True;0;0;False;0;1,1,1,0;1,0.9637939,0.6650944,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;116;2601.463,-276.3075;Float;False;550.4966;547.1101;Emission;3;94;96;97;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1595.098,-128.3557;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;84;2071.665,-877.1222;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;2651.463,-226.3076;Float;True;Property;_Emission;Emission;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;96;2654.686,66.90757;Float;False;Property;_EmissionColor;EmissionColor;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2402.73,388.6313;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;2982.959,137.8024;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;164;3098.417,342.5765;Float;False;285;303;Blend Emission;1;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;43;1065.974,-409.1508;Float;True;Property;_Diffuse;Diffuse;5;0;Create;True;0;0;False;0;None;61535901b60fc2b47afd87456d793813;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3148.417,392.5764;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;3515.123,135.3737;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;1431.674,-245.1835;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3915.351,393.8133;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/Moon;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;True;9999;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;6.95;23.32;False;0.5;False;5;4;False;-1;1;False;-1;0;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0.05;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;68;0;66;0
WireConnection;173;0;157;0
WireConnection;141;0;173;0
WireConnection;141;1;68;0
WireConnection;190;1;199;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;76;0;15;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;100;0;99;0
WireConnection;100;1;57;0
WireConnection;151;0;141;0
WireConnection;79;0;76;0
WireConnection;75;0;151;0
WireConnection;75;1;100;0
WireConnection;75;2;194;0
WireConnection;179;0;151;0
WireConnection;189;0;75;0
WireConnection;180;0;79;0
WireConnection;180;1;179;0
WireConnection;10;0;189;0
WireConnection;10;1;87;0
WireConnection;82;0;83;0
WireConnection;82;1;180;0
WireConnection;42;0;73;0
WireConnection;42;1;10;0
WireConnection;84;0;82;0
WireConnection;85;0;84;0
WireConnection;85;1;42;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;98;0;97;0
WireConnection;98;1;85;0
WireConnection;200;0;43;0
WireConnection;200;1;98;0
WireConnection;74;0;43;0
WireConnection;74;1;73;0
WireConnection;0;9;200;0
WireConnection;0;13;98;0
ASEEND*/
//CHKSM=906E2C4678DB40002FD16C1F60BC126E5378F976