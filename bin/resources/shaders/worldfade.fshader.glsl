#version 400 core

in vec2 fWorldPos;

out vec4 color;

const float worldEndDistance = 1024.0;
const float worldFadeBoundary = 128.0;
const float worldFadeDistance = worldEndDistance - worldFadeBoundary;

void main()
{
    float dist = length(fWorldPos);
    
    if(dist > worldEndDistance)
    {
        color = vec4(0,0,0,1);
    }
    else if(dist > worldFadeDistance)
    {
        float a = (dist - worldFadeDistance) / worldFadeBoundary;
        color = vec4(0, 0, 0, a);
    }
    else
    {
        color = vec4(0, 0, 0, 0);
    }
}
