module lightwave.resources;

import magra.base;
import magra.renderer;
import magra.glutil;

import lightwave.camera;
import xypoint;

QuadBuffer starQB, particleQB, gravQB, glowQB;
Texture2D starTX, glowTX, dotTX;

//Loads a vshader and fshader of the given basename from
//the resources directory.
void setupShaderPair(QuadBuffer qbuf, string basename)
{
    string basepath = getResourcesPath() ~ "shaders/" ~ basename;
    qbuf.setupShader(basepath ~ ".vshader.glsl", basepath ~ ".fshader.glsl");
}

void loadResources()
{
    dotTX = loadTexture("dot.png", 0);
    glowTX = loadTexture("glow.png", 0);
    starTX = loadTexture("bgstars.png", 0);
    
    starQB = new QuadBuffer;
    starQB.addAttribute("vWorldPos", 0, 2);
    starQB.addAttribute("vTexPos", 1, 2);
    starQB.setupShaderPair("background");
    starQB.program.setUniform("tex", 0);
    starQB.addTexture(starTX);
    
    particleQB = new QuadBuffer;
    particleQB.addAttribute("vWorldPos", 0, 2);
    particleQB.addAttribute("vTexPos", 1, 2);
    particleQB.addAttribute("vParticleColor", 2, 4);
    particleQB.setupShaderPair("particle");
    particleQB.program.setUniform("tex", 0);
    particleQB.addTexture(dotTX);
    
    gravQB = new QuadBuffer;
    gravQB.addAttribute("vWorldPos", 0, 2);
    gravQB.addAttribute("vTexPos", 1, 2);
    gravQB.addAttribute("vParticleColor", 2, 4);
    gravQB.setupShaderPair("particle");
    gravQB.program.setUniform("tex", 0);
    gravQB.addTexture(glowTX);
    gravQB.setBlendMode(GL_ONE_MINUS_DST_COLOR, GL_ONE);
    
    glowQB = new QuadBuffer;
    glowQB.addAttribute("vWorldPos", 0, 2);
    glowQB.addAttribute("vTexPos", 1, 2);
    glowQB.addAttribute("vParticleColor", 2, 4);
    glowQB.setupShaderPair("particle");
    glowQB.program.setUniform("tex", 0);
    glowQB.addTexture(glowTX);
    glowQB.setBlendMode(GL_ONE_MINUS_DST_COLOR, GL_ONE);

    renderingQueue.registerLayer(starQB, 0);
    renderingQueue.registerLayer(particleQB, 1);
    renderingQueue.registerLayer(gravQB, 2);
    renderingQueue.registerLayer(glowQB, 3);
}
