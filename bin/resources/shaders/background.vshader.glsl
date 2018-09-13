#version 400 core

in vec2 vWorldPos;
in vec2 vTexPos;

out vec2 fTexPos;

uniform vec2 camOrigin;
uniform vec2 camRange;

void main()
{
    fTexPos = vTexPos;
    gl_Position = vec4(vWorldPos.x, vWorldPos.y, 1.0, 1.0);
}

