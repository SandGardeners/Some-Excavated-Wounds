// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LothsShade/Grass"
{
	Properties
	{
		_TexScale("TexScale", Float) = 1
		[Toggle(_LOCKSIZETOWORLD_ON)] _LockSizetoWorld("Lock Size to World", Float) = 0
		_MainColor("MainColor", Color) = (1,1,1,0)
		_AlbedoLevel("AlbedoLevel", Range( 0 , 5)) = 1
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		[HDR]_ColorRim("ColorRim", Color) = (0,1,0.8758622,0)
		_ShadowOffset("ShadowOffset", Float) = -50
		_ShadeTex("ShadeTex", 2D) = "white" {}
		_Power("Power", Range( 0 , 10)) = 0.5
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		_OffsetRim("OffsetRim", Float) = 0.24
		_BottomBlendColor("BottomBlendColor", Color) = (0,0,0,0)
		_GlobalNoiseMask("GlobalNoiseMask", 2D) = "white" {}
		_AltColor("AltColor", Color) = (0,0,0,0)
		_WorldNoiseScale("WorldNoiseScale", Range( 0.1 , 400)) = 0
		_BottomBlendNoise("BottomBlendNoise", 2D) = "white" {}
		_BottomBlendStrength("BottomBlendStrength", Range( 0 , 1)) = 0
		_BlendNoiseStrength("BlendNoiseStrength", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Off
		ZWrite On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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

		uniform float4 _MainColor;
		uniform float4 _AltColor;
		uniform sampler2D _GlobalNoiseMask;
		uniform float _WorldNoiseScale;
		uniform float4 _BottomBlendColor;
		uniform sampler2D _BottomBlendNoise;
		uniform float4 _BottomBlendNoise_ST;
		uniform float _BlendNoiseStrength;
		uniform float _BottomBlendStrength;
		uniform float _ShadowSharpness;
		uniform float _ShadowOffset;
		uniform float4 _ShadowColor;
		uniform sampler2D _ShadeTex;
		uniform float _TexScale;
		uniform float _ShadeTexIntensity;
		uniform float _AlbedoLevel;
		uniform float _OffsetRim;
		uniform float _Power;
		uniform float4 _ColorRim;

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
			float3 ase_worldPos = i.worldPos;
			float3 break245 = ( ase_worldPos / _WorldNoiseScale );
			float2 appendResult232 = (float2(( break245.x - floor( break245.x ) ) , ( break245.z - floor( break245.z ) )));
			float4 lerpResult230 = lerp( _MainColor , _AltColor , tex2D( _GlobalNoiseMask, saturate( appendResult232 ) ));
			float2 uv_BottomBlendNoise = i.uv_texcoord * _BottomBlendNoise_ST.xy + _BottomBlendNoise_ST.zw;
			float4 temp_cast_0 = (0.5).xxxx;
			float4 lerpResult221 = lerp( lerpResult230 , _BottomBlendColor , ( saturate( ( ( 1.0 - i.uv_texcoord.y ) + ( ( tex2D( _BottomBlendNoise, uv_BottomBlendNoise ) - temp_cast_0 ) * _BlendNoiseStrength ) ) ) * _BottomBlendStrength ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( ase_worldNormal , ase_worldlightDir );
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
			UnityGI gi11 = gi;
			float3 diffNorm11 = ase_worldNormal;
			gi11 = UnityGI_Base( data, 1, diffNorm11 );
			float3 indirectDiffuse11 = gi11.indirect.diffuse + diffNorm11 * 0.0001;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult204 = dot( ase_worldNormal , ase_worldViewDir );
			c.rgb = ( ( lerpResult221 * ( ( ase_lightColor * saturate( ( saturate( ( saturate( (ase_lightAtten*_ShadowSharpness + _ShadowOffset) ) * saturate( (saturate( (dotResult3*0.5 + 0.5) )*_ShadowSharpness + _ShadowOffset) ) ) ) + _ShadowColor + lerpResult194 ) ) * _AlbedoLevel ) + float4( indirectDiffuse11 , 0.0 ) ) ) + ( saturate( ( ( ase_lightAtten * dotResult3 ) * pow( ( 1.0 - saturate( ( dotResult204 + _OffsetRim ) ) ) , _Power ) ) ) * ( _ColorRim * ase_lightColor ) ) ).rgb;
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
1940;123;1886;1010;-1772.137;936.4274;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;48;-3083.118,113.1246;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3019.117,321.1245;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-2496.471,-70.26369;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-2971.117,161.1245;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-2446.471,186.9073;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2683.116,225.1245;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1631.698,349.8171;Float;False;671.4778;278.8033;Comment;3;155;157;173;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-208.9855,-306.6022;Float;False;Property;_WorldNoiseScale;WorldNoiseScale;17;0;Create;True;0;0;False;0;0;299;0.1;400;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-2174.509,-20.2637;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;231;-44.28279,-648.8492;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;168;-1711.836,-88.41492;Float;False;736.9673;335.4506;Comment;4;66;59;67;68;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;246;229.6583,-348.3638;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1661.836,39.56157;Float;False;Property;_ShadowSharpness;ShadowSharpness;6;0;Create;True;0;0;False;0;100;95.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;200;1405.402,789.8167;Float;False;507.201;385.7996;Comment;3;204;202;201;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;155;-1581.698,403.6204;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1968.471,-28.17758;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1641.013,132.0357;Float;False;Property;_ShadowOffset;ShadowOffset;8;0;Create;True;0;0;False;0;-50;-51.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;202;1501.401,997.8156;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;66;-1401.144,-38.24265;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;201;1453.401,837.8157;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;203;1956.652,688.1919;Float;False;1617.938;553.8222;;14;218;217;215;214;213;212;211;210;209;208;207;206;205;216;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;245;370.5519,-568.455;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ScaleAndOffsetNode;157;-1336.779,399.8171;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;264;2007.137,-384.4274;Float;True;Property;_BottomBlendNoise;BottomBlendNoise;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;268;1986.137,-172.4274;Float;False;Constant;_Float1;Float 1;21;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;173;-1135.22,404.5137;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;2039.385,960.1934;Float;False;Property;_OffsetRim;OffsetRim;12;0;Create;True;0;0;False;0;0.24;1.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-796.7751,-84.30011;Float;False;285;303;Comment;1;141;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;204;1757.401,917.8157;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;238;808.8569,-619.939;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;348.9681,875.8676;Float;False;ScreenspaceUV;0;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.FloorOpNode;240;750.8571,-378.7202;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-1149.869,-38.41495;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;2182.137,-156.4274;Float;False;Property;_BlendNoiseStrength;BlendNoiseStrength;22;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;267;2408.137,-347.4274;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;193;600.0136,1024.007;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;11;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;222;2117.49,-746.6253;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;244;954.9992,-433.8123;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;206;2244.655,848.1929;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-746.7751,-34.30014;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;405.8759,288.985;Float;False;540.2805;466.2345;Comment;1;57;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;190;584.4673,810.9363;Float;True;Property;_ShadeTex;ShadeTex;9;0;Create;True;0;0;False;0;None;c164bae765f280a4985a2f436103b626;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;243;971.9992,-722.8123;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;232;1113.976,-557.2924;Float;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;194;918.3002,911.7262;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;170;1440.484,266.2136;Float;False;285;303;Comment;1;75;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;207;2404.654,848.1929;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;487.616,548.2197;Float;False;Property;_ShadowColor;ShadowColor;5;0;Create;True;0;0;False;0;0,0,0,0;0.05253288,0.4433962,0.03555536,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;2596.137,-341.4274;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;223;2413.69,-665.7249;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;-531.6902,-28.90755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;269;2603.137,-575.4274;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;242;1450.949,-479.5543;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;176;2027.117,-54.56987;Float;False;626.4951;467.9142;Comment;3;10;8;87;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;1490.483,320.2502;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;115;2831.859,-152.871;Float;False;649.3216;496.598;Comment;4;73;229;230;221;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;208;2580.654,848.1929;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;209;2548.285,743.8015;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;2468.654,976.1935;Float;False;Property;_Power;Power;10;0;Create;True;0;0;False;0;0.5;0.44;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;212;2772.654,848.1929;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;2109.789,-464.2249;Float;False;Property;_BottomBlendStrength;BottomBlendStrength;21;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;2060.026,244.8053;Float;False;Property;_AlbedoLevel;AlbedoLevel;4;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;227;1629.997,-489.1671;Float;True;Property;_GlobalNoiseMask;GlobalNoiseMask;14;0;Create;True;0;0;False;0;None;b6f5ef030b0a64a409fcdb7b9224e095;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;229;2836.874,92.08709;Float;False;Property;_AltColor;AltColor;15;0;Create;True;0;0;False;0;0,0,0,0;0.6603774,0.08410462,0.1392568,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;270;2764.137,-512.4274;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;2813.265,735.7047;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;2831.184,-100.9582;Float;False;Property;_MainColor;MainColor;3;0;Create;True;0;0;False;0;1,1,1,0;0.8773585,0.368325,0.7667278,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;189;1795.664,413.1634;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;8;2217.714,3.42963;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;226;2998.807,-864.837;Float;False;Property;_BottomBlendColor;BottomBlendColor;13;0;Create;True;0;0;False;0;0,0,0,0;0.07062117,0.216981,0.1363947,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;11;2217.488,477.1894;Float;False;Tangent;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;213;2932.654,960.1934;Float;False;Property;_ColorRim;ColorRim;7;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0.6603774,0,0.04867986,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;230;3084.118,-86.52242;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;2997.931,734.3915;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;2451.59,23.82473;Float;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;2942.891,-467.625;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;215;3044.654,1136.193;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;221;3303.09,-118.9249;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;220;2690.485,473.9268;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;216;3215.782,723.9265;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;3236.655,944.1932;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;3396.654,816.1929;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;3546.329,121.9906;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;214.2831,-509.9548;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;255;3591.827,910.5669;Float;False;Property;_WaveInfluence;WaveInfluence;20;0;Create;True;0;0;False;0;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;260;3680.226,1192.68;Float;False;Property;_WaveFrequency;WaveFrequency;16;0;Create;True;0;0;False;0;0.7;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;3659.226,1266.68;Float;False;Property;_WaveStrength;WaveStrength;18;0;Create;True;0;0;False;0;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;263;3802.268,940.1588;Float;False;Waving Vertex;-1;;18;872b3757863bb794c96291ceeebfb188;0;3;15;FLOAT3;0,0,0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;219;3789.421,675.4015;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;3640.226,1087.68;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;261;3372.226,1299.68;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4052.39,446.0858;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;LothsShade/Grass;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;False;False;False;False;Off;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;6.95;23.32;False;0.5;True;0;1;False;-1;10;False;-1;0;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0.05;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;246;0;231;0
WireConnection;246;1;233;0
WireConnection;15;0;4;0
WireConnection;66;0;15;0
WireConnection;66;1;59;0
WireConnection;66;2;67;0
WireConnection;245;0;246;0
WireConnection;157;0;155;0
WireConnection;157;1;59;0
WireConnection;157;2;67;0
WireConnection;173;0;157;0
WireConnection;204;0;201;0
WireConnection;204;1;202;0
WireConnection;238;0;245;0
WireConnection;240;0;245;2
WireConnection;68;0;66;0
WireConnection;267;0;264;0
WireConnection;267;1;268;0
WireConnection;244;0;245;2
WireConnection;244;1;240;0
WireConnection;206;0;204;0
WireConnection;206;1;205;0
WireConnection;141;0;173;0
WireConnection;141;1;68;0
WireConnection;190;1;199;0
WireConnection;243;0;245;0
WireConnection;243;1;238;0
WireConnection;232;0;243;0
WireConnection;232;1;244;0
WireConnection;194;1;190;4
WireConnection;194;2;193;0
WireConnection;207;0;206;0
WireConnection;266;0;267;0
WireConnection;266;1;265;0
WireConnection;223;0;222;2
WireConnection;151;0;141;0
WireConnection;269;0;223;0
WireConnection;269;1;266;0
WireConnection;242;0;232;0
WireConnection;75;0;151;0
WireConnection;75;1;57;0
WireConnection;75;2;194;0
WireConnection;208;0;207;0
WireConnection;212;0;208;0
WireConnection;212;1;210;0
WireConnection;227;1;242;0
WireConnection;270;0;269;0
WireConnection;211;0;209;0
WireConnection;211;1;3;0
WireConnection;189;0;75;0
WireConnection;230;0;73;0
WireConnection;230;1;229;0
WireConnection;230;2;227;0
WireConnection;214;0;211;0
WireConnection;214;1;212;0
WireConnection;10;0;8;0
WireConnection;10;1;189;0
WireConnection;10;2;87;0
WireConnection;224;0;270;0
WireConnection;224;1;225;0
WireConnection;221;0;230;0
WireConnection;221;1;226;0
WireConnection;221;2;224;0
WireConnection;220;0;10;0
WireConnection;220;1;11;0
WireConnection;216;0;214;0
WireConnection;217;0;213;0
WireConnection;217;1;215;0
WireConnection;218;0;216;0
WireConnection;218;1;217;0
WireConnection;42;0;221;0
WireConnection;42;1;220;0
WireConnection;234;0;231;0
WireConnection;234;1;233;0
WireConnection;263;15;262;0
WireConnection;263;12;260;0
WireConnection;263;13;259;0
WireConnection;219;0;42;0
WireConnection;219;1;218;0
WireConnection;262;0;255;0
WireConnection;262;1;261;2
WireConnection;0;13;219;0
ASEEND*/
//CHKSM=945FEA8C9647CA0FBBF7B4EAFC6E56A94B9B88A4