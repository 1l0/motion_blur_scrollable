#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform float u_delta;
uniform float u_angle;
uniform sampler2D u_texture;

out vec4 fragColor;

float random(vec3 scale, float seed, vec3 xyz) {
    return fract(sin(dot(xyz + seed, scale)) * 43758.5453 + seed);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / u_size;
    vec4 color = vec4(0.0);
    float total = 0.0;
    vec2 tDelta = u_delta * vec2(cos(u_angle), sin(u_angle));
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0, vec3(fragCoord, 1000.0));
    for(float t = -30.0; t <= 30.0; t++) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 saample = texture(u_texture, uv + tDelta * percent);
        saample.rgb *= saample.a;
        color += saample * weight;
        total += weight;
    }

    if(total == 0.)
        total = 1.;
    fragColor = color / total;
    fragColor.rgb = fragColor.rgb / fragColor.a + 0.01;
}
