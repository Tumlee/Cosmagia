#version 400 core

#define PI 3.1415926

uniform sampler2D tex;
uniform sampler2D ctex;

in vec2 fTexPos;
in float fVelAng;
in float fVelMag;
in float fAlpha;

out vec4 color;

void main()
{
    vec2 cPos;
    cPos.x = fVelAng / (2 * PI);
    cPos.y = fVelMag * 8.0;
    
    color = texture(tex, fTexPos) * texture(ctex, cPos) * fAlpha;
}
