#ifndef LIGHTING_T_INCLUDED
#define LIGHTING_T_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

void GetMainLightInfo_float(out float3 direction, out half3 color)
{
    #if defined(SHADERGRAPH_PREVIEW)
    direction = float3(1, 1, -1);
    color = 1;
    #else
    Light mainLight = GetMainLight();
    direction = mainLight.direction;
    color = mainLight.color;
    #endif
}

void ComputeAdditionalLightingToon_float(float3 normalWS, float3 positionWS, UnityTexture2D toonRamp,
                                        UnitySamplerState sState, out float3 diffuse)
{
    diffuse = 0;
    
    
    #if !defined(SHADERGRAPH_PREVIEW)
    
    
    int lightCount = GetAdditionalLightsCount();
    
    [unroll(8)]
    for (int lightId = 0; lightId < lightCount; lightId++)
    {
        Light light = GetAdditionalLight(lightId, positionWS);
        half halfLambert = dot(normalWS, light.direction) * 0.5 + 0.5;
        half4 toonDiffuse = SAMPLE_TEXTURE2D(toonRamp, sState ,halfLambert);
        diffuse += toonDiffuse * light.color * light.distanceAttenuation;

    }
    #endif
}

void Add_float(float a, float b, out float c)
{
    c = a + b;
}
#endif