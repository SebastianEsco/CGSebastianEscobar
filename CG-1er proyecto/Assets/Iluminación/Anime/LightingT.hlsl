#ifndef LIGHTING_T_INCLUDED
#define LIGHTING_T_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

void GetMainLightInfo_float(float3 positionWS, out float3 direction, out half3 color, out float shadowAttenuation)
{
#if defined(SHADERGRAPH_PREVIEW)
    direction = float3(1, 1, -1);
    color = 1;
    shadowAttenuation = 1;
#else
    Light mainLight = GetMainLight();
    direction = mainLight.direction;
    color = mainLight.color;
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    float shadowStrength = GetMainLightShadowStrength();
    ShadowSamplingData samplingData = GetMainLightShadowSamplingData();
    shadowAttenuation = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), samplingData, shadowStrength, false);
#endif
}

void ComputeAdditionalLightingToon_float(float3 normalWS, float3 positionWS, UnityTexture2D toonRamp,
                                        UnitySamplerState sState,float3 viewDirWS,float specularHarndness, out float3 diffuse, out float3 specular)
{
    diffuse = 0;
    specular = 0;
    
    #if !defined(SHADERGRAPH_PREVIEW)
    
    
    int lightCount = GetAdditionalLightsCount();
    
    [unroll(8)]
    for (int lightId = 0; lightId < lightCount; lightId++)
    {
        
        //Diffuse Lighting
        Light light = GetAdditionalLight(lightId, positionWS);
        half halfLambert = dot(normalWS, light.direction) * 0.5 + 0.5;
        half4 toonDiffuse = SAMPLE_TEXTURE2D(toonRamp, sState, saturate(halfLambert));
        diffuse += toonDiffuse * light.color * light.distanceAttenuation;
        
        //Specular lighting
        float3 h = normalize(light.direction + viewDirWS);
        float blinnPhong = dot(h, normalWS);
        blinnPhong = max(blinnPhong, 0.0f);
        
        float power = lerp(30, 300, specularHarndness);
        blinnPhong = pow(blinnPhong, power);
        blinnPhong = smoothstep(0, 0.02f, blinnPhong);
        specular = blinnPhong * light.color * light.distanceAttenuation;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

    }
    #endif
}

void Add_float(float a, float b, out float c)
{
    c = a + b;
}
#endif