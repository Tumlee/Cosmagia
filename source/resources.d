module lightwave.resources;

import magra.base;
import magra.extras.graphics;

Layer backLayer, gravLayer, particleLayer, glowLayer;
SDL_Texture* bgstars, bgcolor;
SDL_Texture*[2] colorStars;
SDL_Texture* bg;

SDL_Texture* dot;
SDL_Texture* glow;

void loadResources()
{
    dot = loadTexture("dot.png");
    glow = loadTexture("glow.png");
    bgstars = loadTexture("bgstars.png");
    bgcolor = loadTexture("bgcolor.png");

    bg = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 1366, 768);

    foreach(i; 0 .. colorStars.length)
    {
        colorStars[i] = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET,
                                            texWidth(bgstars), texHeight(bgstars));
    }

    SDL_SetTextureBlendMode(glow, SDL_BLENDMODE_ADD);
    SDL_SetTextureBlendMode(bgcolor, SDL_BLENDMODE_MOD);
    SDL_SetTextureBlendMode(colorStars[0], SDL_BLENDMODE_ADD);
    SDL_SetTextureBlendMode(colorStars[1], SDL_BLENDMODE_ADD);
    
    backLayer = canvas.register(0);
    particleLayer = canvas.register(1);
    gravLayer = canvas.register(2);
    glowLayer = canvas.register(3);
}
