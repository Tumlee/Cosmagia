#version 400 core

in vec2 vWorldPos;

out vec2 fWorldPos;

uniform vec2 camOrigin;
uniform vec2 camRange;

void main()
{
    fWorldPos = vWorldPos * camRange + camOrigin;
    gl_Position = vec4(vWorldPos.x, vWorldPos.y, 1.0, 1.0);
}

