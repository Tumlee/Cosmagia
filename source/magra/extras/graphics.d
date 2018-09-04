module magra.extras.graphics;

import magra.base;

int texWidth(SDL_Texture* texture)
{
    int w;
    SDL_QueryTexture(texture, null, null, &w, null);
    
    return w;
}

int texHeight(SDL_Texture* texture)
{
    int h;
    SDL_QueryTexture(texture, null, null, null, &h);
    
    return h;
}

class BasicSprite : Drawer
{
    SDL_Texture* texture;
    int x, y;
    SDL_RendererFlip flip;
    
    this(SDL_Texture* tex, int xx, int yy, SDL_RendererFlip fl = SDL_FLIP_NONE)
    {
        texture = tex;
        x = xx;
        y = yy;
        flip = fl;
    }

    override void draw(SDL_Renderer* target)
    {
        SDL_Rect location;
        
        location.x = x;
        location.y = y;
        location.w = cast(int) texWidth(texture);
        location.h = cast(int) texHeight(texture);
        
        SDL_RenderCopyEx(target, texture, null, &location, 0.0, null, flip);
    }
}

class Sprite : Drawer
{
    SDL_Texture* texture;
    int x, y;
    float scale;
    float rotation;
    
    this(SDL_Texture* tex, int xx, int yy, float scl = 1.0, float rot = 0.0)
    {
        texture = tex;
        scale = scl;
        x = cast(int)(xx - (texWidth(texture) * scale * .5));
        y = cast(int)(yy - (texHeight(texture) * scale * .5));
        rotation = rot;
    }
    
    override void draw(SDL_Renderer* target)
    {
        SDL_Rect location;
        
        location.x = x;
        location.y = y;
        location.w = cast(int) (texWidth(texture) * scale);
        location.h = cast(int) (texHeight(texture) * scale);
        
        SDL_RenderCopyEx(target, texture, null, &location, rotation, null, SDL_FLIP_NONE);
    }
}

class ClearDrawer : Drawer
{
    this()
    {
    }
    
    override void draw(SDL_Renderer* target)
    {
        SDL_SetRenderDrawColor(target, 0, 0, 0, 0);
        SDL_RenderClear(target);
    }
}
