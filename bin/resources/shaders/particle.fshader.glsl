#version 420 core

uniform sampler2D tex;

in vec2 fTexPos;
in vec2 fScreenPos;
in vec4 fParticleColor;

out vec4 color;

void main()
{
    color = texture(tex, fTexPos) * fParticleColor;
}
