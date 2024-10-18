//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

void GetMainLight_float(float3 positionWS, out float3 direction, out float3 color, out float shadowAttenuation){
    #if !defined(SHADERGRAPH_PREVIEW)
    Light light;
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    light = GetMainLight(shadowCoord);
    direction = light.direction;
    color = light.color;

    ShadowSamplingData shadowData = GetMainLightShadowSamplingData();
    float shadowIntensity = GetMainLightShadowStrength();

    shadowAttenuation = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowData, shadowIntensity, false);

    #else
    direction = float3(1, 1, -1);
    color = 1;
    shadowAttenuation = 1;
    #endif
}

void ShadeToonAdditionalLights_float(float3 normalWS, float3 positionWS, UnityTexture2D toonGrading, UnitySamplerState sState, 
    float3 viewDirWS, half smoothness, out half3 diffuse, out half3 specular){
    
    diffuse = (0, 0, 0);
    specular = (0, 0, 0);

    #if !defined(SHADERGRAPH_PREVIEW)    
    int additionalLightCount = GetAdditionalLightsCount();
    
    [unroll(8)]
    for(int lightId = 0; lightId < additionalLightCount; lightId++){

        Light additionalLight =  GetAdditionalLight(lightId, positionWS);

        //Diffuse
        half halfLambert = dot(normalWS, additionalLight.direction) * 0.5 + 0.5;
        diffuse += SAMPLE_TEXTURE2D(toonGrading, sState, halfLambert) * additionalLight.color * additionalLight.distanceAttenuation;


        //Specular
        float3 h = normalize(additionalLight.direction + viewDirWS);
        half blinnPhong = max(0, dot(normalWS, h));

        blinnPhong = pow(blinnPhong, 50);
        blinnPhong = smoothstep(0.5, 0.6, blinnPhong);
        blinnPhong *= smoothness;
        specular += blinnPhong * additionalLight.color * additionalLight.distanceAttenuation;
    }
    #endif
}