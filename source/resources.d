module lightwave.resources;

import magra.base;
import magra.renderer;

QuadBuffer starQB, particleQB, gravQB, glowQB;
/*SDL_Texture* bgstars, bgcolor;
SDL_Texture*[2] colorStars;
SDL_Texture* bg;

SDL_Texture* dot;
SDL_Texture* glow;*/

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
    /*dot = loadTexture("dot.png");
    glow = loadTexture("glow.png");
    bgstars = loadTexture("bgstars.png");
    bgcolor = loadTexture("bgcolor.png");

    bg = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 1366, 768);

    foreach(i; 0 .. colorStars.length)
    {
        colorStars[i] = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET,
                                            texWidth(bgstars), texHeight(bgstars));
    }*/
}
