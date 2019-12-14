// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( DistanceBlurPPSRenderer ), PostProcessEvent.AfterStack, "DistanceBlur", true )]
public sealed class DistanceBlurPPSSettings : PostProcessEffectSettings
{
}

public sealed class DistanceBlurPPSRenderer : PostProcessEffectRenderer<DistanceBlurPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DistanceBlur" ) );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
