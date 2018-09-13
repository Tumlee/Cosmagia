#version 400 core

uniform sampler2D tex;

in vec2 fTexPos;

out vec4 color;

void main()
{
    color = texture(tex, fTexPos);
}
