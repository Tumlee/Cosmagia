module lightwave.resources;

import magra.base;
import magra.renderer;
import magra.glutil;

QuadBuffer starQB, particleQB, gravQB, glowQB;
Texture2D starTX, glowTX, dotTX;

void loadResources()
{
    starQB = new QuadBuffer;
    particleQB = new QuadBuffer;
    gravQB = new QuadBuffer;
    glowQB = new QuadBuffer;

    renderingQueue.registerLayer(starQB, 0);
    renderingQueue.registerLayer(particleQB, 1);
    renderingQueue.registerLayer(gravQB, 2);
    renderingQueue.registerLayer(glowQB, 3);
    
    dotTX = loadTexture("dot.png", 0);
    glowTX = loadTexture("glow.png", 0);
    starTX = loadTexture("bgstars.png", 0);
}
