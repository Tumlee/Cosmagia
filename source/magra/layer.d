module magra.layer;

import derelict.sdl2.sdl;
import magra.canvas;
import magra.drawer;

class Layer
{
    Drawer[] drawers;
    Canvas container;
    int camx, camy;
    int ordering;

    void draw()
    {        
        foreach(drawer; drawers)
            drawer.draw(container.targetRenderer);
    }
    
    void add(lazy Drawer drawer)
    {
        if(container.enabled)
            drawers ~= drawer;
    }
    
    void clear()
    {
        drawers.length = 0;
    }
}
