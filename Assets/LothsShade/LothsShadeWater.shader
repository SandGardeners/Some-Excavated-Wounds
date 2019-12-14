// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/Water"
{
	Properties
	{
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
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
		_NormalScale("NormalScale", Float) = 1
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Float) = 100
		_DeepShadeScale("DeepShadeScale", Float) = 0
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_ShadowOffset("ShadowOffset", Float) = -50
		_DeepShadeOffset("DeepShadeOffset", Float) = 0
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		_SparkleSharpness("SparkleSharpness", Float) = 0
		_WaveSpeed("WaveSpeed", Float) = 0
		_SparkleTiling("SparkleTiling", Float) = 0
		_Normals("Normals", 2D) = "white" {}
		[HDR]_SparkleColour("SparkleColour", Color) = (0,0,0,0)
		_SparkleNoise("SparkleNoise", 2D) = "white" {}
		_Smoothness("Smoothness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZTest Less
			ZWrite On
		}

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Off
		ZWrite On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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

		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _EmissionColor;
		uniform float4 _HighlightColor;
		uniform sampler2D _Normals;
		uniform float _NormalScale;
		uniform float _WaveSpeed;
		uniform float _SparkleTiling;
		uniform float _HighlightSharpness;
		uniform float _HighlightOffset;
		uniform float _ShadowSharpness;
		uniform float _ShadowOffset;
		uniform float _DeepShadeScale;
		uniform float _DeepShadeOffset;
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
		uniform float4 _SparkleColour;
		uniform float _Smoothness;
		uniform float _Shininess;
		uniform sampler2D _SparkleNoise;
		uniform float _SparkleSharpness;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;

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
			float2 temp_cast_0 = (_WaveSpeed).xx;
			float2 temp_cast_1 = (_SparkleTiling).xx;
			float2 uv_TexCoord247 = i.uv_texcoord * temp_cast_1;
			float2 panner243 = ( _Time.y * temp_cast_0 + uv_TexCoord247);
			float3 tex2DNode91 = UnpackScaleNormal( tex2D( _Normals, panner243 ), _NormalScale );
			float2 temp_cast_2 = (_WaveSpeed).xx;
			float2 temp_cast_3 = (50.0).xx;
			float2 uv_TexCoord283 = i.uv_texcoord * temp_cast_3;
			float2 panner285 = ( _Time.y * temp_cast_2 + uv_TexCoord283);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( (WorldNormalVector( i , BlendNormals( tex2DNode91 , ( UnpackScaleNormal( tex2D( _Normals, panner285 ), _NormalScale ) * 50.0 ) ) )) , ase_worldlightDir );
			float temp_output_15_0 = saturate( (dotResult3*0.5 + 0.5) );
			float temp_output_151_0 = saturate( ( saturate( (ase_lightAtten*_ShadowSharpness + _ShadowOffset) ) * saturate( (temp_output_15_0*_ShadowSharpness + _ShadowOffset) ) ) );
			float4 clampResult84 = clamp( ( _HighlightColor * ( saturate( (temp_output_15_0*_HighlightSharpness + _HighlightOffset) ) - ( 1.0 - temp_output_151_0 ) ) ) , float4( 0,0,0,0 ) , float4( 0.5,0.5,0.5,0 ) );
			float temp_output_259_0 = saturate( (ase_lightAtten*_DeepShadeScale + _DeepShadeOffset) );
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi11 = gi;
			float3 diffNorm11 = ase_worldNormal;
			gi11 = UnityGI_Base( data, 1, diffNorm11 );
			float3 indirectDiffuse11 = gi11.indirect.diffuse + diffNorm11 * 0.0001;
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
			float4 temp_cast_7 = (_Smoothness).xxxx;
			float4 temp_output_43_0_g8 = temp_cast_7;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult4_g9 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g8 = normalize( (WorldNormalVector( i , tex2DNode91 )) );
			float dotResult19_g8 = dot( normalizeResult4_g9 , normalizeResult64_g8 );
			float4 temp_output_40_0_g8 = ( ase_lightColor * ase_lightAtten );
			float dotResult14_g8 = dot( normalizeResult64_g8 , ase_worldlightDir );
			UnityGI gi34_g8 = gi;
			float3 diffNorm34_g8 = normalizeResult64_g8;
			gi34_g8 = UnityGI_Base( data, 1, diffNorm34_g8 );
			float3 indirectDiffuse34_g8 = gi34_g8.indirect.diffuse + diffNorm34_g8 * 0.0001;
			float4 color233 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 temp_output_42_0_g8 = color233;
			float2 temp_cast_11 = (_WaveSpeed).xx;
			float2 panner253 = ( ( ( 1.0 - _Time.y ) / 1.7 ) * temp_cast_11 + uv_TexCoord247);
			float4 temp_cast_12 = (_SparkleSharpness).xxxx;
			float4 temp_output_98_0 = ( ( tex2D( _Emission, uv_Emission ) * _EmissionColor ) + ( clampResult84 + ( temp_output_259_0 * ( ( tex2D( _Diffuse, uv_Diffuse ) * _MainColor ) * ( float4( indirectDiffuse11 , 0.0 ) + ( ase_lightColor * _AlbedoLevel * saturate( ( temp_output_151_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult194 ) ) ) ) ) ) + ( ( _SparkleColour * ( ( float4( (temp_output_43_0_g8).rgb , 0.0 ) * (temp_output_43_0_g8).a * pow( max( dotResult19_g8 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g8 ) + ( ( ( temp_output_40_0_g8 * max( dotResult14_g8 , 0.0 ) ) + float4( indirectDiffuse34_g8 , 0.0 ) ) * float4( (temp_output_42_0_g8).rgb , 0.0 ) ) ) * step( ( tex2D( _SparkleNoise, panner243 ) * tex2D( _SparkleNoise, panner253 ) ) , temp_cast_12 ) ) * ase_lightAtten * temp_output_259_0 ) ) );
			float dotResult38 = dot( ase_worldNormal , ase_worldViewDir );
			c.rgb = ( temp_output_98_0 + ( saturate( ( ( temp_output_151_0 * dotResult3 ) * pow( ( 1.0 - saturate( ( dotResult38 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) ).rgb;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nolightmap  nodirlightmap 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
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
1933;123;1886;1010;-1844.803;-219.358;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;282;-4685.777,130.0729;Float;False;Constant;_Float0;Float 0;36;0;Create;True;0;0;False;0;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-602.0409,959.1303;Float;False;Property;_SparkleTiling;SparkleTiling;33;0;Create;True;0;0;False;0;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;244;-464,1328;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;283;-4282.343,310.7667;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;245;-346.9274,1209.52;Float;False;Property;_WaveSpeed;WaveSpeed;32;0;Create;True;0;0;False;0;0;0.004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;268;-4154.837,-242.6442;Float;True;Property;_Normals;Normals;34;0;Create;True;0;0;False;0;None;0b099f8fbac461345b2a4bf38d9538e2;True;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;285;-4052.721,484.1973;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.01,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-4174.907,213.2485;Float;False;Property;_NormalScale;NormalScale;15;0;Create;True;0;0;False;0;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;247;-288,1008;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;243;16,1168;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;269;-3889.011,272.8457;Float;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;False;0;None;c1ad52c6b913ce247ae933cd6d8cea55;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;91;-3717.629,-234.3486;Float;True;Property;_NormalMap;NormalMap;15;0;Create;True;0;0;False;0;None;c1ad52c6b913ce247ae933cd6d8cea55;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-3517.877,322.431;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;271;-3289.355,214.4754;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;48;-3083.118,113.1246;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3019.117,321.1245;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1;-2971.117,161.1245;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-2496.471,-70.26369;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2446.471,186.9073;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2683.116,225.1245;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;168;-1711.836,-88.41492;Float;False;736.9673;335.4506;Comment;4;66;59;67;68;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1631.698,349.8171;Float;False;671.4778;278.8033;Comment;3;155;157;173;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2174.509,-20.2637;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1968.471,-28.17758;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1581.698,403.6204;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1661.836,39.56157;Float;False;Property;_ShadowSharpness;ShadowSharpness;22;0;Create;True;0;0;False;0;100;95.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1641.013,132.0357;Float;False;Property;_ShadowOffset;ShadowOffset;23;0;Create;True;0;0;False;0;-50;-43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1336.779,399.8171;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1401.144,-38.24265;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-1149.869,-38.41495;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1135.22,404.5137;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;-1623.671,1325.591;Float;False;ScreenspaceUV;4;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;169;-1492.34,697.8774;Float;False;540.2805;466.2345;Comment;3;57;100;99;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;-796.7751,-84.30011;Float;False;285;303;Comment;1;141;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-746.7751,-34.30014;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;1324.259,840.2087;Float;False;507.201;385.7996;Comment;3;36;37;38;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;248;-224,1360;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;190;-1098.233,1325.09;Float;True;Property;_ShadeTex;ShadeTex;25;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-1442.341,747.8774;Float;True;Property;_ShadowMap;ShadowMap;20;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-1074.633,1218.692;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;26;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-1410.6,957.1122;Float;False;Property;_ShadowColor;ShadowColor;21;0;Create;True;0;0;False;0;0,0,0,0;0.1329847,0.117647,0.6784314,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;36;1372.259,888.2084;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;1420.259,1048.208;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;170;-46.79288,650.1136;Float;False;285;303;Comment;1;75;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;865.1548,-1110.3;Float;False;1381.51;553.5251;Comment;9;84;82;180;83;79;179;76;77;78;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;50;1886.406,821.9999;Float;False;1617.938;553.8222;;14;33;46;32;31;34;47;35;30;29;28;27;25;24;7;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;151;-531.6902,-28.90755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;249;-48,1392;Float;False;2;0;FLOAT;0;False;1;FLOAT;1.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1116.401,896.8563;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;194;-560.3695,1095.672;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;253;144,1424;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;252;-491.4343,1452.855;Float;True;Property;_SparkleNoise;SparkleNoise;36;0;Create;True;0;0;False;0;None;bdbe94d7623ec3940947b62544306f1c;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;77;915.1548,-869.0199;Float;False;Property;_HighlightSharpness;HighlightSharpness;17;0;Create;True;0;0;False;0;100;199.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;136.4948,44.19838;Float;False;606.4951;329.9142;Comment;2;10;8;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;3.2069,704.1502;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;78;945.7184,-779.5408;Float;False;Property;_HighlightOffset;HighlightOffset;19;0;Create;True;0;0;False;0;-80;-192.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;38;1676.259,968.2081;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;1966.407,1094.001;Float;False;Property;_RimOffset;Rim Offset;9;0;Create;True;0;0;False;0;0.24;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;2174.408,982.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;228;304.6189,1110.64;Float;True;Property;_SparkleNoise1;SparkleNoise1;40;0;Create;True;0;0;False;0;None;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;76;1187.049,-985.1174;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;78.1535,468.8882;Float;False;Property;_AlbedoLevel;AlbedoLevel;12;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;189;303.0161,791.6942;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;115;1187.071,-394.7511;Float;False;649.3216;496.598;Comment;4;73;43;74;42;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;8;327.0912,102.1983;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;250;366.0663,1358.357;Float;True;Property;_SparkleNoise2;SparkleNoise2;40;0;Create;True;0;0;False;0;None;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;27;2334.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;233;789.0843,338.6903;Float;False;Constant;_Color0;Color 0;34;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;803.554,1217.016;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;255;1392.762,87.17942;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;237;520.6528,813.0214;Float;False;Property;_SparkleSharpness;SparkleSharpness;30;0;Create;True;0;0;False;0;0;0.001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;257;1386.573,248.9104;Float;False;Property;_DeepShadeOffset;DeepShadeOffset;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;79;1453.825,-897.3636;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;1199.589,-110.9206;Float;False;Property;_MainColor;MainColor;10;0;Create;True;0;0;False;0;1,1,1,0;0.233357,0.3495347,0.7169812,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;179;1438.546,-803.7609;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;1205.893,-347.6611;Float;True;Property;_Diffuse;Diffuse;11;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;11;693.2306,-92.22028;Float;False;Tangent;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;560.9684,122.5935;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;229;541.8769,514.8038;Float;False;Property;_Smoothness;Smoothness;38;0;Create;True;0;0;False;0;0;10.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;1383.834,162.6604;Float;False;Property;_DeepShadeScale;DeepShadeScale;18;0;Create;True;0;0;False;0;0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;2510.407,982.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;258;1605.59,112.9875;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;231;1022.656,436.3075;Float;True;Blinn-Phong Light;0;;8;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;COLOR;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;1603.548,-872.7587;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;1659.127,-1060.3;Float;False;Property;_HighlightColor;HighlightColor;16;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;0.2743414,0.3928425,0.4245283,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;1512.114,-198.8811;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;226;1042.328,251.0478;Float;False;Property;_SparkleColour;SparkleColour;35;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1.844303,1.844303,1.844303,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;262;1006.656,99.21223;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;296;1092.94,850.9174;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;2398.407,1110.001;Float;False;Property;_RimPower;Rim Power;8;0;Create;True;0;0;False;0;0.5;8.6;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;2686.408,869.9999;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;2702.407,982.001;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;259;1837.374,111.2734;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;241;1606.615,577.0191;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1922.558,-882.899;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1639.898,-131.5557;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;1556.728,344.7523;Float;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;116;2601.463,-276.3075;Float;False;550.4966;547.1101;Emission;3;94;96;97;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2942.408,950.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;242;1925.949,462.9258;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;2074.765,123.0003;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;2651.463,-226.3076;Float;True;Property;_Emission;Emission;13;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;84;2071.665,-877.1222;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;34;2862.407,1094.001;Float;False;Property;_RimColor;Rim Color;7;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0.7836311,3.291673,3.691773,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;96;2654.686,66.90757;Float;False;Property;_EmissionColor;EmissionColor;14;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;47;2974.407,1270.001;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;2982.959,137.8024;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;32;3134.408,950.001;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;3166.408,1078.001;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;164;3064.274,268.698;Float;False;285;303;Blend Emission;1;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2294.627,218.3686;Float;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3114.274,318.6978;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;123;3588.704,765.1691;Float;False;204;183;Blend Rim Light;1;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;3326.407,950.001;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;217;3611.604,1055.219;Float;False;Property;_Foam;Foam;27;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomStandardSurface;238;811.8525,551.7214;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;236;1057.352,737.2214;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;3638.704,815.1692;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;7;2457.145,871.4141;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;575.2527,736.3212;Float;False;Property;_Occlusion;Occlusion;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;542.7527,654.4212;Float;False;Property;_Metallic;Metallic;31;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;2659.212,740.4659;Float;False;Property;_Transparency;Transparency;37;0;Create;True;0;0;False;0;0;0.637;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;287;3342.737,589.0596;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;221;2921.803,561.2734;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;2728.485,623.0526;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;286;3053.953,663.7737;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;218;2478.488,466.8853;Float;False;Global;_GrabScreen0;Grab Screen 0;2;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;222;2451.694,641.6122;Float;False;Property;_ShallowColor;ShallowColor;28;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,1.551396,1.866066,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;3522.127,526.7865;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;263;2248.838,469.1223;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;220;3752.999,451.0228;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4386.861,361.5181;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/Water;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;False;Off;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;1;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;6.95;23.32;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;1;False;-1;0;False;0.05;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;283;0;282;0
WireConnection;285;0;283;0
WireConnection;285;2;245;0
WireConnection;285;1;244;0
WireConnection;247;0;265;0
WireConnection;243;0;247;0
WireConnection;243;2;245;0
WireConnection;243;1;244;0
WireConnection;269;0;268;0
WireConnection;269;1;285;0
WireConnection;269;5;92;0
WireConnection;91;0;268;0
WireConnection;91;1;243;0
WireConnection;91;5;92;0
WireConnection;281;0;269;0
WireConnection;281;1;282;0
WireConnection;271;0;91;0
WireConnection;271;1;281;0
WireConnection;1;0;271;0
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
WireConnection;248;0;244;0
WireConnection;190;1;199;0
WireConnection;151;0;141;0
WireConnection;249;0;248;0
WireConnection;100;0;99;0
WireConnection;100;1;57;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;253;0;247;0
WireConnection;253;2;245;0
WireConnection;253;1;249;0
WireConnection;75;0;151;0
WireConnection;75;1;100;0
WireConnection;75;2;194;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;25;0;38;0
WireConnection;25;1;24;0
WireConnection;228;0;252;0
WireConnection;228;1;243;0
WireConnection;76;0;15;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;189;0;75;0
WireConnection;250;0;252;0
WireConnection;250;1;253;0
WireConnection;27;0;25;0
WireConnection;254;0;228;0
WireConnection;254;1;250;0
WireConnection;79;0;76;0
WireConnection;179;0;151;0
WireConnection;10;0;8;0
WireConnection;10;1;87;0
WireConnection;10;2;189;0
WireConnection;29;0;27;0
WireConnection;258;0;255;0
WireConnection;258;1;256;0
WireConnection;258;2;257;0
WireConnection;231;42;233;0
WireConnection;231;52;91;0
WireConnection;231;43;229;0
WireConnection;180;0;79;0
WireConnection;180;1;179;0
WireConnection;74;0;43;0
WireConnection;74;1;73;0
WireConnection;262;0;11;0
WireConnection;262;1;10;0
WireConnection;296;0;254;0
WireConnection;296;1;237;0
WireConnection;35;0;151;0
WireConnection;35;1;3;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;259;0;258;0
WireConnection;82;0;83;0
WireConnection;82;1;180;0
WireConnection;42;0;74;0
WireConnection;42;1;262;0
WireConnection;227;0;226;0
WireConnection;227;1;231;0
WireConnection;227;2;296;0
WireConnection;31;0;35;0
WireConnection;31;1;30;0
WireConnection;242;0;227;0
WireConnection;242;1;241;0
WireConnection;242;2;259;0
WireConnection;260;0;259;0
WireConnection;260;1;42;0
WireConnection;84;0;82;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;32;0;31;0
WireConnection;46;0;34;0
WireConnection;46;1;47;0
WireConnection;85;0;84;0
WireConnection;85;1;260;0
WireConnection;85;2;242;0
WireConnection;98;0;97;0
WireConnection;98;1;85;0
WireConnection;33;0;32;0
WireConnection;33;1;46;0
WireConnection;238;0;233;0
WireConnection;238;3;240;0
WireConnection;238;4;229;0
WireConnection;238;5;239;0
WireConnection;39;0;98;0
WireConnection;39;1;33;0
WireConnection;287;0;286;0
WireConnection;221;0;218;0
WireConnection;221;1;224;0
WireConnection;221;2;223;0
WireConnection;224;0;218;0
WireConnection;224;1;222;0
WireConnection;286;0;255;0
WireConnection;286;1;256;0
WireConnection;286;2;257;0
WireConnection;288;0;287;0
WireConnection;288;1;221;0
WireConnection;220;0;288;0
WireConnection;220;1;98;0
WireConnection;0;13;39;0
ASEEND*/
//CHKSM=2840CB933352A53B9F66EECDED98EA5B12E619F8