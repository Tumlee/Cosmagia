module lightwave.drawers;

import magra.base;
import magra.extras.graphics;
import std.math;
import xypoint;
import lightwave.resources;

//A round-robin queue of positions a particle has been in.
//This is used for motion-blur effects, so we don't have to
//use a very large number of Drawers when drawing objects with motion blur trails.
class PositionQueue
{
    private XYPoint[] positions;
    private ulong maxElements;
    private ulong current;

    this(uint mElements)
    {
        maxElements = mElements;
    }

    @property ulong numPositions()
    {
        return positions.length;
    }

    void pushPosition(XYPoint newPoint)
    {
        if(positions.length < maxElements)
        {
            positions ~= newPoint;
            current = positions.length - 1;
        }
        else
        {
            current = (current + 1) % maxElements;
            positions[current] = newPoint;
        }
    }

    //Gets the appropriate position where x=(numPositions-1) is the current position.
    //x should never be >= numPositions
    XYPoint getPosition(ulong x)
    {
        assert(x < numPositions);

        return positions[(x + current + 1) % numPositions];
    }
}

//Returns a number from 0 to 1, determines the value of a given color component
//based on an angle expressed in radians.
float aToColorVal(float a)
{
    //Scale this angle so that 2PI gets scaled to 6.0
    float scaled = fmod((a + (2.0 * PI)) * 6.0 / (2.0 * PI), 6.0);
    float frac = fmod(scaled, 1.0);

    if(scaled < 1.0)
        return 1.0;

    if(scaled < 2.0)
        return 1.0 - frac;

    if(scaled < 4.0)
        return 0.0;

    if(scaled < 5.0)
        return frac;

    return 1.0;
}

//Takes a number 0.0 through 1.0, and scales it
//to V(1 - S) to V
float scaleBySV(float x, float s, float v)
{
    return v * (x * s + 1 - s);
}

ubyte floatTo255(float f)
{
    return cast(ubyte) (f * 255.0);
}

SDL_Rect getSourceRect(SDL_Texture* texture, float x, float y, float scale)
{
    SDL_Rect location;

    location.x = cast(int)(x - (texWidth(texture) * scale * .5));
    location.y = cast(int)(y - (texHeight(texture) * scale * .5));
    location.w = cast(int)(texWidth(texture) * scale);
    location.h = cast(int)(texHeight(texture) * scale);

    return location;
}

class CParticle : Drawer
{
    SDL_Texture* texture;
    XYPoint pos;
    float scale;
    float h, s, v, a;
    
    this(SDL_Texture* tex, XYPoint p, float hh, float ss, float vv, float aa, float scl = 1.0)
    {
        texture = tex;
        scale = scl;
        h = hh;
        s = ss;
        v = vv;
        a = aa;
        pos = p;
    }
    
    override void draw(SDL_Renderer* target)
    {
        SDL_Rect location;
        
        location.x = cast(int)(pos.x - (texWidth(texture) * scale * .5));
        location.y = cast(int)(pos.y - (texHeight(texture) * scale * .5));
        location.w = cast(int) (texWidth(texture) * scale);
        location.h = cast(int) (texHeight(texture) * scale);

        float r = aToColorVal(h).scaleBySV(s, v);
        float g = aToColorVal(h + (PI * 2.0 / 3.0)).scaleBySV(s, v);
        float b = aToColorVal(h + (PI * 4.0 / 3.0)).scaleBySV(s, v);
        
        SDL_SetTextureColorMod(texture, r.floatTo255, g.floatTo255, b.floatTo255);
        SDL_SetTextureAlphaMod(texture, a.floatTo255);
        SDL_RenderCopyEx(target, texture, null, &location, 0.0, null, SDL_FLIP_NONE);
    }
}

class TParticle : Drawer
{
    SDL_Texture* texture;
    PositionQueue pqueue;
    float scale;
    float h, s, v, a;
    
    this(SDL_Texture* tex, PositionQueue pq, float hh, float ss, float vv, float aa, float scl = 1.0)
    {
        texture = tex;
        scale = scl;
        h = hh;
        s = ss;
        v = vv;
        a = aa;
        pqueue = pq;
    }
    
    override void draw(SDL_Renderer* target)
    {
        float r = aToColorVal(h).scaleBySV(s, v);
        float g = aToColorVal(h + (PI * 2.0 / 3.0)).scaleBySV(s, v);
        float b = aToColorVal(h + (PI * 4.0 / 3.0)).scaleBySV(s, v);
        
        SDL_SetTextureColorMod(texture, r.floatTo255, g.floatTo255, b.floatTo255);

        foreach(i; 0 .. pqueue.numPositions)
        {
            auto pos = pqueue.getPosition(i);
            auto currentScale = scale * (.5 + (.5 * (i + 1) / pqueue.numPositions));
            SDL_Rect location = getSourceRect(texture, pos.x, pos.y, currentScale);
            auto currentAlpha = i == (pqueue.numPositions - 1) ? 1.0 : (a * (i + 1) * .5) / (pqueue.numPositions);

            SDL_SetTextureAlphaMod(texture, currentAlpha.floatTo255);
            SDL_RenderCopyEx(target, texture, null, &location, 0.0, null, SDL_FLIP_NONE);
        }
    }
}

class BGDrawer : Drawer
{
    float time;

    this(float t)
    {
        time = t;
    }
    
    override void draw(SDL_Renderer* target)
    {
        //Draw stars onto colorStars
        foreach(i; 0 .. colorStars.length)
        {
            SDL_SetRenderTarget(target, colorStars[i]);

            auto starRot = [3.5, -2.0][i] * time;
            auto colorRot = [8.5, -4.0][i] * time - starRot;
            
            auto location = getSourceRect(bgstars, texWidth(colorStars[i]) * .5, texHeight(colorStars[i]) * .5, 1.0);
            SDL_RenderCopyEx(target, bgstars, null, &location, starRot, null, SDL_FLIP_NONE);

            //Draw bgcolor onto colorStars
            location = getSourceRect(bgcolor, texWidth(colorStars[i]) * .5, texHeight(colorStars[i]) * .5, 1.5);
            SDL_RenderCopyEx(target, bgcolor, null, &location, colorRot, null, SDL_FLIP_NONE);
        }

        //Clear the main background to black, put colorStars onto it.
        SDL_SetRenderTarget(target, bg);
        SDL_SetRenderDrawColor(target, 0, 0, 0, 0);
        SDL_RenderClear(target);

        auto location1 = getSourceRect(colorStars[0], texWidth(bg) * .3, texHeight(bg) * .5 + sin(time * .02) * 40.0, 2.0);
        auto location2 = getSourceRect(colorStars[1], texWidth(bg) * .7, texHeight(bg) * .5 + sin(time * .02 + 4) * 40.0, 2.0);
        SDL_RenderCopyEx(target, colorStars[0], null, &location1, 0.0, null, SDL_FLIP_NONE);
        SDL_RenderCopyEx(target, colorStars[1], null, &location2, 0.0, null, SDL_FLIP_NONE);

        //Draw the background onto the screen.
        SDL_SetRenderTarget(target, null);

        auto finalLocation = getSourceRect(bg, 1366 / 2, 768 / 2, 1.0);
        SDL_RenderCopyEx(target, bg, null, &finalLocation, 0.0, null, SDL_FLIP_NONE);
    }
}

