module lightwave.resources;

import magra.base;
import magra.renderer;
import magra.glutil;

import lightwave.camera;
import xypoint;

QuadBuffer starQB, particleQB, gravQB, glowQB;
Texture2D starTX, glowTX, dotTX;
Texture2D pcolorTX, gcolorTX;

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
    pcolorTX = loadTexture("pcolormap.png", 1);
    gcolorTX = loadTexture("gcolormap.png", 1);
    pcolorTX.setWrapping(GL_REPEAT, GL_CLAMP_TO_EDGE);
    gcolorTX.setWrapping(GL_REPEAT, GL_CLAMP_TO_EDGE);
    
    starQB = new QuadBuffer;
    starQB.addAttribute("vWorldPos", 0, 2);
    starQB.addAttribute("vTexPos", 1, 2);
    starQB.setupShaderPair("background");
    starQB.program.setUniform("tex", 0);
    starQB.addTexture(starTX);
    
    particleQB = new QuadBuffer;
    particleQB.addAttribute("vWorldPos", 0, 2);
    particleQB.addAttribute("vTexPos", 1, 2);
    particleQB.addAttribute("vVel", 2, 2);
    particleQB.addAttribute("vAlpha", 3, 1);
    particleQB.setupShaderPair("particle");
    particleQB.program.setUniform("tex", 0);
    particleQB.program.setUniform("ctex", 1);
    particleQB.addTexture(dotTX);
    particleQB.addTexture(pcolorTX);
    
    gravQB = new QuadBuffer;
    gravQB.addAttribute("vWorldPos", 0, 2);
    gravQB.addAttribute("vTexPos", 1, 2);
    gravQB.addAttribute("vVel", 2, 2);
    gravQB.addAttribute("vAlpha", 3, 1);
    gravQB.setupShaderPair("glow");
    gravQB.program.setUniform("tex", 0);
    gravQB.program.setUniform("ctex", 1);
    gravQB.addTexture(glowTX);
    gravQB.addTexture(gcolorTX);
    gravQB.setBlendMode(GL_ONE_MINUS_DST_COLOR, GL_ONE);
    
    glowQB = new QuadBuffer;
    glowQB.addAttribute("vWorldPos", 0, 2);
    glowQB.addAttribute("vTexPos", 1, 2);
    glowQB.addAttribute("vVel", 2, 2);
    glowQB.addAttribute("vAlpha", 3, 1);
    glowQB.setupShaderPair("glow");
    glowQB.program.setUniform("tex", 0);
    glowQB.program.setUniform("ctex", 1);
    glowQB.addTexture(glowTX);
    glowQB.addTexture(gcolorTX);
    glowQB.setBlendMode(GL_ONE_MINUS_DST_COLOR, GL_ONE);

    renderingQueue.registerLayer(starQB, 0);
    renderingQueue.registerLayer(particleQB, 1);
    renderingQueue.registerLayer(gravQB, 2);
    renderingQueue.registerLayer(glowQB, 3);
}
