module magra.canvas;

import derelict.sdl2.sdl;
import std.algorithm;
import std.range;
import std.exception;

import magra.layer;

class Canvas
{
    Layer[] layers;
    SDL_Renderer* targetRenderer;
    bool enabled = true;
    
    Layer register(int ordering)
    {
        auto layer = new Layer;
    
        layer.ordering = ordering;
        layer.container = this;
        layers ~= layer;
        layers = layers.sort!((a, b) => a.ordering < b.ordering).array;
        
        return layer;
    }
    
    void draw()
    {
        enforce(targetRenderer !is null, "Drew to a null renderer");
    
        if(enabled)
        {
            foreach(layer; layers)
                layer.draw();
        }
    }
    
    void clear()
    {
        foreach(layer; layers)
            layer.clear();
    }
}
