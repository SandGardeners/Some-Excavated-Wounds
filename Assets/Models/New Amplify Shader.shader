// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "New Amplify Shader"
{
	Properties
	{
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_Color1("Color 1", Color) = (0,0.947295,1,0)
		_voronoi("voronoi", Float) = 0
		[HDR]_RimColor("Rim Color", Color) = (0,1,0.8758622,0)
		_RimPower("Rim Power", Range( 0 , 100)) = 0.5
		_RimOffset("Rim Offset", Float) = 0.24
		_MainColor("MainColor", Color) = (1,1,1,0)
		_AlbedoLevel("AlbedoLevel", Range( 0 , 5)) = 1
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 1
		_HighlightColor("HighlightColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_HighlightSharpness("HighlightSharpness", Range( 0 , 200)) = 100
		_HighlightOffset("HighlightOffset", Float) = -80
		_ShadowMap("ShadowMap", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 100
		_ShadowOffset("ShadowOffset", Float) = -50
		_ShadeTexIntensity("ShadeTexIntensity", Range( 0 , 1)) = 0
		_BottomBlendColor("BottomBlendColor", Color) = (0,0,0,0)
		_BottomBlendStrength("BottomBlendStrength", Range( 0 , 1)) = 0
		_DeepShadeScale("DeepShadeScale", Float) = 0
		_DeepShadeOffset("DeepShadeOffset", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _HighlightSharpness;
		uniform float _HighlightOffset;
		uniform float _ShadowSharpness;
		uniform float _ShadowOffset;
		uniform float4 _Color0;
		uniform float4 _Color1;
		uniform float _voronoi;
		uniform float2 _Vector0;
		uniform float4 _MainColor;
		uniform float4 _BottomBlendColor;
		uniform float _BottomBlendStrength;
		uniform float _AlbedoLevel;
		uniform sampler2D _ShadowMap;
		uniform float4 _ShadowMap_ST;
		uniform float4 _ShadowColor;
		uniform float _ShadeTexIntensity;
		uniform float _DeepShadeScale;
		uniform float _DeepShadeOffset;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;


		float2 voronoihash1( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1( float2 v, inout float2 id )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash1( n + g );
					o = ( sin( 1.0 + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = max(abs(r.x), abs(r.y));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F2 - F1;
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
			float dotResult19 = dot( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale ) )) , ase_worldlightDir );
			float temp_output_36_0 = saturate( (dotResult19*0.5 + 0.5) );
			float temp_output_44_0 = saturate( (ase_lightAtten*_ShadowSharpness + _ShadowOffset) );
			float temp_output_45_0 = saturate( (temp_output_36_0*_ShadowSharpness + _ShadowOffset) );
			float temp_output_48_0 = saturate( ( temp_output_44_0 * temp_output_45_0 ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi92 = gi;
			float3 diffNorm92 = ase_worldNormal;
			gi92 = UnityGI_Base( data, 1, diffNorm92 );
			float3 indirectDiffuse92 = gi92.indirect.diffuse + diffNorm92 * 0.0001;
			float4 clampResult111 = clamp( ( _HighlightColor * ( saturate( (temp_output_36_0*_HighlightSharpness + _HighlightOffset) ) - ( 1.0 - temp_output_48_0 ) ) * ase_lightColor * float4( indirectDiffuse92 , 0.0 ) ) , float4( 0,0,0,0 ) , float4( 0.5,0.5,0.5,0 ) );
			float2 uv_TexCoord2 = i.uv_texcoord * ( _CosTime + float4( _Vector0, 0.0 , 0.0 ) ).xy;
			float2 coords1 = uv_TexCoord2 * _voronoi;
			float2 id1 = 0;
			float voroi1 = voronoi1( coords1, id1 );
			float4 lerpResult5 = lerp( _Color0 , _Color1 , round( voroi1 ));
			float4 diffuse133 = lerpResult5;
			float4 lerpResult84 = lerp( _MainColor , _BottomBlendColor , ( ( 1.0 - i.uv_texcoord.y ) * _BottomBlendStrength ));
			float2 uv_ShadowMap = i.uv_texcoord * _ShadowMap_ST.xy + _ShadowMap_ST.zw;
			float lerpResult55 = lerp( 0.0 , 0.0 , _ShadeTexIntensity);
			float lerpResult63 = lerp( 0.0 , lerpResult55 , ( 1.0 - temp_output_48_0 ));
			UnityGI gi91 = gi;
			float3 diffNorm91 = ase_worldNormal;
			gi91 = UnityGI_Base( data, 1, diffNorm91 );
			float3 indirectDiffuse91 = gi91.indirect.diffuse + diffNorm91 * 0.0001;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult65 = dot( ase_worldNormal , ase_worldViewDir );
			c.rgb = ( ( ( tex2D( _Emission, uv_Emission ) * _EmissionColor ) + ( clampResult111 + ( ( ( diffuse133 * lerpResult84 ) * ( ( ase_lightColor * _AlbedoLevel * saturate( ( temp_output_48_0 + ( tex2D( _ShadowMap, uv_ShadowMap ) * _ShadowColor ) + lerpResult63 ) ) ) + float4( indirectDiffuse91 , 0.0 ) ) ) * saturate( (ase_lightAtten*_DeepShadeScale + _DeepShadeOffset) ) ) ) ) + ( saturate( ( ( ase_lightAtten * dotResult19 ) * pow( ( 1.0 - saturate( ( dotResult65 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) ).rgb;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
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
Version=17000
1920;1;1906;1011;3216.808;641.1428;1.356563;True;True
Node;AmplifyShaderEditor.RangedFloatNode;12;-6660.324,1446.897;Float;False;Property;_NormalScale;NormalScale;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-6172.968,1383.32;Float;False;540.401;320.6003;Comment;3;19;16;15;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;13;-6475.358,1402.069;Float;True;Property;_NormalMap;NormalMap;14;0;Create;True;0;0;False;0;None;77fdad851e93f394c9f8a1b1a63b56f3;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;15;-6060.967,1431.32;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;16;-6110.047,1591.32;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;17;-5544.138,1244.597;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;36;25;21;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;19;-5772.966,1495.32;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-5471.138,1438.768;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;24;-4583.751,1634.507;Float;False;671.4778;278.8033;Comment;3;44;39;35;Stylize Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4667.692,1243.815;Float;False;736.9673;335.4506;Comment;4;45;40;32;31;Stylize Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;25;-5222.176,1294.597;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-5022.538,1297.883;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-4639.692,1378.792;Float;False;Property;_ShadowSharpness;ShadowSharpness;21;0;Create;True;0;0;False;0;100;482.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;35;-4557.751,1678.31;Float;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-4628.869,1470.266;Float;False;Property;_ShadowOffset;ShadowOffset;22;0;Create;True;0;0;False;0;-50;-180.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;40;-4357.001,1293.987;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;39;-4308.332,1691.007;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;11;-3209.234,-372.959;Float;False;1344.254;683.4362;Diffuse;11;7;9;8;2;10;3;4;1;6;5;135;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CosTime;9;-3159.234,-173.4591;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;7;-3052.634,-322.959;Float;False;Property;_Vector0;Vector 0;0;0;Create;True;0;0;False;0;0,0;100,100;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;42;-3628.447,1230.876;Float;False;443.2562;289.4352;Comment;2;48;46;Combine Shade, Lightmap and Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;44;-4106.768,1674.839;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-4107.233,1294.919;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-3942.04,2559.815;Float;False;830.347;382.0016;Shadow texture;4;126;125;55;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-3578.447,1280.876;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-2886.234,-155.2591;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;50;-4257.131,2013.31;Float;False;540.2805;466.2345;Comment;3;62;53;52;Colour Shade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-3653.757,2826.817;Float;False;Property;_ShadeTexIntensity;ShadeTexIntensity;24;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-3327.781,1363.694;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2734.08,-296.4227;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-3046.084,122.5944;Float;False;Property;_voronoi;voronoi;6;0;Create;True;0;0;False;0;0;0.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1;-2655.981,-103.0507;Float;True;0;3;2.88;2;1;False;5;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.ColorNode;53;-4175.391,2272.545;Float;False;Property;_ShadowColor;ShadowColor;20;0;Create;True;0;0;False;0;0,0,0,0;0.8207547,0.352305,0.6073499,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;-4207.132,2063.31;Float;True;Property;_ShadowMap;ShadowMap;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;54;-1865.599,2651.424;Float;False;507.201;385.7996;Comment;3;65;60;56;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;51;-3003.052,2497.322;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-3295.693,2622.397;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;56;-1817.599,2699.424;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;60;-1769.599,2859.423;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;3;-2349.967,-142.9606;Float;False;Property;_Color0;Color 0;4;0;Create;True;0;0;False;0;0,0,0,0;0,0.7019608,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-3881.191,2212.289;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RoundOpNode;135;-2322.19,35.09951;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-2125.927,703.9854;Float;False;1381.51;553.5251;Comment;11;111;105;100;99;97;92;87;85;75;70;66;Stylize and Colour Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-3014.894,1626.032;Float;False;285;303;Comment;1;64;Add shade colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1270.418,2652.454;Float;False;1617.938;553.8222;;14;122;120;117;115;109;108;107;106;101;95;93;82;78;72;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;4;-2399.425,144.5325;Float;False;Property;_Color1;Color 1;5;0;Create;True;0;0;False;0;0,0.947295,1,0;1,0.03593232,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-1978.399,1840.62;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;63;-2773.578,2508.976;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-2134.98,-94.82268;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2017.758,1483.309;Float;False;Property;_BottomBlendStrength;BottomBlendStrength;26;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2712.51,1516.872;Float;False;606.4951;329.9142;Light colour;3;83;79;73;Ambient and Light Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;65;-1513.599,2779.424;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;-1671.443,1907.914;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1190.417,2924.455;Float;False;Property;_RimOffset;Rim Offset;9;0;Create;True;0;0;False;0;0.24;0.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2075.927,945.2657;Float;False;Property;_HighlightSharpness;HighlightSharpness;17;0;Create;True;0;0;False;0;100;30;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2045.364,1034.745;Float;False;Property;_HighlightOffset;HighlightOffset;18;0;Create;True;0;0;False;0;-80;620.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-2964.894,1680.068;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-1891.489,-193.9807;Float;True;diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1472.03,1959.903;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;75;-1804.033,829.1682;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-982.4168,2812.455;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-1770.479,2193.945;Float;False;524.3274;303;Add indirect lighting;2;94;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;76;-2588.573,1988.517;Float;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;79;-2597.913,1546.872;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;73;-2671.134,1753.492;Float;False;Property;_AlbedoLevel;AlbedoLevel;11;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;68;-1484.264,1424.051;Float;False;649.3216;496.598;Comment;4;102;96;84;134;Diffuse Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;81;-1792.589,1654.562;Float;False;Property;_BottomBlendColor;BottomBlendColor;25;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;80;-1533.938,1698.411;Float;False;Property;_MainColor;MainColor;10;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;85;-1551.548,1050.496;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;87;-1503.257,905.9221;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;86;-1147.768,2179.372;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1117.557,2347.602;Float;False;Property;_DeepShadeOffset;DeepShadeOffset;28;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;-1285.54,1735.5;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1147.596,2263.952;Float;False;Property;_DeepShadeScale;DeepShadeScale;27;0;Create;True;0;0;False;0;0;814.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;82;-822.4178,2812.455;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1420.433,1464.261;Float;True;133;diffuse;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2339.336,1581.968;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;91;-1720.479,2321.449;Float;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;98;-905.0399,2180.479;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-646.4178,2812.455;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;99;-1331.955,753.9854;Float;False;Property;_HighlightColor;HighlightColor;16;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-1328.534,948.5268;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1196.621,1472.721;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;100;-1530.579,735.5617;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;101;-838.0208,2707.13;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;92;-1367.969,1170.905;Float;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-1468.352,2261.545;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-758.4178,2940.455;Float;False;Property;_RimPower;Rim Power;8;0;Create;True;0;0;False;0;0.5;2.8;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1081.524,926.3867;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-470.4171,2700.454;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1039.438,1690.447;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;104;-632.2557,2267.765;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;107;-454.418,2812.455;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-618.4349,606.6053;Float;False;550.4966;547.1101;Emission;3;116;113;110;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-214.4171,2780.455;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-296.0049,1796.386;Float;False;285;303;Blend Highlights;1;119;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;111;-957.1168,926.7634;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-462.6861,2170.542;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;110;-568.4349,656.6052;Float;True;Property;_Emission;Emission;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;113;-565.2117,949.82;Float;False;Property;_EmissionColor;EmissionColor;13;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;115;-182.418,3100.455;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;109;-294.418,2924.455;Float;False;Property;_RimColor;Rim Color;7;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;9.583126,2908.455;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;120;-22.41687,2780.455;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;148.2552,1782.461;Float;False;285;303;Blend Emission;1;124;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-246.0049,1846.386;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-236.939,1020.715;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;198.2552,1832.461;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;121;-3840.123,1593.97;Float;False;234;306.1558;Alternate blend modes;2;132;127;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;123;399.5992,2104.843;Float;False;204;183;Blend Rim Light;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;154.3722,2761.866;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;6;-2258.38,-293.3227;Float;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;431.9991,2118.043;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;125;-3892.04,2643.975;Float;False;ScreenspaceUV;1;;7;f76d51f1c30427d4a8aef47a88e21453;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-3771.607,1643.97;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;-3668.556,2609.815;Float;True;Property;_ShadeTex;ShadeTex;23;0;Create;True;0;0;False;0;None;7130c16fd8005b546b111d341310a9a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;127;-3790.123,1744.125;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;938.3937,2252.351;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;New Amplify Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;5;12;0
WireConnection;15;0;13;0
WireConnection;19;0;15;0
WireConnection;19;1;16;0
WireConnection;25;0;19;0
WireConnection;25;1;21;0
WireConnection;25;2;21;0
WireConnection;36;0;25;0
WireConnection;40;0;36;0
WireConnection;40;1;31;0
WireConnection;40;2;32;0
WireConnection;39;0;35;0
WireConnection;39;1;31;0
WireConnection;39;2;32;0
WireConnection;44;0;39;0
WireConnection;45;0;40;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;8;0;9;0
WireConnection;8;1;7;0
WireConnection;48;0;46;0
WireConnection;2;0;8;0
WireConnection;1;0;2;0
WireConnection;1;2;10;0
WireConnection;51;0;48;0
WireConnection;55;2;49;0
WireConnection;62;0;52;0
WireConnection;62;1;53;0
WireConnection;135;0;1;0
WireConnection;63;1;55;0
WireConnection;63;2;51;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;5;2;135;0
WireConnection;65;0;56;0
WireConnection;65;1;60;0
WireConnection;69;0;61;2
WireConnection;64;0;48;0
WireConnection;64;1;62;0
WireConnection;64;2;63;0
WireConnection;133;0;5;0
WireConnection;74;0;69;0
WireConnection;74;1;71;0
WireConnection;75;0;36;0
WireConnection;75;1;70;0
WireConnection;75;2;66;0
WireConnection;78;0;65;0
WireConnection;78;1;72;0
WireConnection;76;0;64;0
WireConnection;85;0;48;0
WireConnection;87;0;75;0
WireConnection;84;0;80;0
WireConnection;84;1;81;0
WireConnection;84;2;74;0
WireConnection;82;0;78;0
WireConnection;83;0;79;0
WireConnection;83;1;73;0
WireConnection;83;2;76;0
WireConnection;98;0;86;0
WireConnection;98;1;90;0
WireConnection;98;2;88;0
WireConnection;95;0;82;0
WireConnection;97;0;87;0
WireConnection;97;1;85;0
WireConnection;96;0;134;0
WireConnection;96;1;84;0
WireConnection;94;0;83;0
WireConnection;94;1;91;0
WireConnection;105;0;99;0
WireConnection;105;1;97;0
WireConnection;105;2;100;0
WireConnection;105;3;92;0
WireConnection;106;0;101;0
WireConnection;106;1;19;0
WireConnection;102;0;96;0
WireConnection;102;1;94;0
WireConnection;104;0;98;0
WireConnection;107;0;95;0
WireConnection;107;1;93;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;111;0;105;0
WireConnection;114;0;102;0
WireConnection;114;1;104;0
WireConnection;117;0;109;0
WireConnection;117;1;115;0
WireConnection;120;0;108;0
WireConnection;119;0;111;0
WireConnection;119;1;114;0
WireConnection;116;0;110;0
WireConnection;116;1;113;0
WireConnection;124;0;116;0
WireConnection;124;1;119;0
WireConnection;122;0;120;0
WireConnection;122;1;117;0
WireConnection;6;0;2;0
WireConnection;128;0;124;0
WireConnection;128;1;122;0
WireConnection;132;0;45;0
WireConnection;132;1;44;0
WireConnection;126;1;125;0
WireConnection;127;0;45;0
WireConnection;127;1;44;0
WireConnection;127;2;21;0
WireConnection;0;13;128;0
ASEEND*/
//CHKSM=492BD8F76AE087D726C6C73E05E3595E67354F10