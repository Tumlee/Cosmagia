#version 420 core

in vec2 vWorldPos;
in vec2 vTexPos;

out vec2 fTexPos;
out vec2 fScreenPos;

uniform vec2 camOrigin;
uniform vec2 camRange;

//NOTE: Is vScreenPos even needed here?
void main()
{
    fTexPos = vTexPos;
    fScreenPos = vWorldPos;
    gl_Position = vec4(fScreenPos.x, fScreenPos.y, 1.0, 1.0);
}

