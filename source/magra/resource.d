module magra.resource;

import magra.globals;

import std.string;
import std.exception;

/*SDL_Texture* loadTexture(const char[] filename)
{
    enforce(renderer !is null, "Loaded a texture without a renderer.");
    
    auto surface = IMG_Load(("resources/" ~ filename).toStringz);
    
    if(surface is null)
        return null;
    
    auto texture = SDL_CreateTextureFromSurface(renderer, surface);
    
    SDL_FreeSurface(surface);
    
    return texture;
}*/

//FIXME-GLFW: This is to be handled by OpenAL later on.
/*Mix_Chunk* loadSound(const char[] filename)
{
    return Mix_LoadWAV(("resources/" ~ filename).toStringz);
}*/

/*Mix_Music* loadMusic(const char[] filename)
{
    return Mix_LoadMUS(("resources/" ~ filename).toStringz);
}*/
