#version 400 core

in vec2 vWorldPos;
in vec2 vTexPos;
in vec2 vVel;
in float vAlpha;

out vec2 fTexPos;
out float fVelAng;
out float fVelMag;
out float fAlpha;

uniform vec2 camOrigin;
uniform vec2 camRange;

void main()
{
    fTexPos = vTexPos;
    vec2 screenPos = (vWorldPos - camOrigin) / camRange;
    fVelAng = atan(vVel.y, vVel.x);
    fVelMag = sqrt((vVel.x * vVel.x) + (vVel.y * vVel.y));
    fAlpha = vAlpha;
    gl_Position = vec4(screenPos.x, screenPos.y, 1.0, 1.0);
}

