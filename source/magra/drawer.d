module magra.drawer;

import std.exception;
import derelict.sdl2.sdl;

import magra.layer;

class Drawer
{    
    abstract void draw(SDL_Renderer* target);
}
