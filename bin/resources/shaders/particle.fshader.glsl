#version 420 core

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
    cPos.y = fVelMag * 6.0;
    color = texture(tex, fTexPos) * texture(ctex, cPos) * vec4(1, 1, 1, fAlpha);
}
