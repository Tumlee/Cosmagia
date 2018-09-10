#version 420 core

in vec2 vWorldPos;
in vec2 vTexPos;
in vec4 vParticleColor;

out vec2 fTexPos;
out vec4 fParticleColor;

uniform vec2 camOrigin;
uniform vec2 camRange;

//NOTE: Is vScreenPos even needed here?
void main()
{
    fTexPos = vTexPos;
    vec2 screenPos = (vWorldPos - camOrigin) / camRange;
    fParticleColor = vParticleColor;
    gl_Position = vec4(screenPos.x, screenPos.y, 1.0, 1.0);
}

