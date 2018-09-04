module magra.input;

import derelict.sdl2.sdl;

enum KeyState
{
    up,
    down,
    released,
    fresh
}

class Keyboard
{
    //Keys are created dynamically as they are pressed.
    KeyState[int] keys;
    
    void handleEvent(SDL_Event event)
    {
        if(event.type == SDL_KEYDOWN && !event.key.repeat)
            keys[event.key.keysym.sym] = KeyState.fresh;
        
        if(event.type == SDL_KEYUP && !event.key.repeat)
            keys[event.key.keysym.sym] = KeyState.released;
    }
    
    void update()
    {
        //FIXME: Maybe std.algorithm replace() function?
        foreach(ref state; keys)
        {
            if(state.isFresh)
                state = KeyState.down;

            if(state.isReleased)
                state = KeyState.up;
        }
    }
    
    void clear()
    {
        foreach(ref state; keys)
        {
            if(state.isDown)
                state = KeyState.released;
        }
    }
    
    KeyState opIndex(int key)
    {
        return keys.get(key, KeyState.up);
    }
}

class Mouse
{
    KeyState[int] buttons;
    
    //Information about current state of buttons.
    int x, y;
    int dx, dy;
    int wheelx, wheely;
    
    //Information that is accumulated through events,
    //and actually takes effect later. 
    int accRelx, accRely;
    int accWheelx, accWheely;
    
    void handleEvent(SDL_Event event)
    {
        if(event.type == SDL_MOUSEBUTTONDOWN)
            buttons[event.button.button] = KeyState.fresh;
            
        if(event.type == SDL_MOUSEBUTTONUP)
            buttons[event.button.button] = KeyState.released;
            
        if(event.type == SDL_MOUSEMOTION)
        {
            x = event.motion.x;
            y = event.motion.y;
            
            accRelx = event.motion.xrel;
            accRely = event.motion.yrel;
        }
        
        if(event.type == SDL_MOUSEWHEEL)
        {
            accWheelx += event.wheel.x;
            accWheely += event.wheel.y;
        }
    }
    
    void update()
    {
        dx = accRelx;
        dy = accRely;
        
        wheelx = accWheelx;
        wheely = accWheely;
        
        accRelx = 0;
        accRely = 0;
        
        accWheelx = 0;
        accWheely = 0;
    
        foreach(ref state; buttons)
        {
            if(state.isFresh)
                state = KeyState.down;

            if(state.isReleased)
                state = KeyState.up;
        }
    }
    
    void clear()
    {
        foreach(ref state; buttons)
        {
            if(state.isDown)
                state = KeyState.released;
        }
    }

    KeyState opIndex(int but)
    {
        return buttons.get(but, KeyState.up);
    }
}

bool isDown(KeyState state)
{
    return state == KeyState.down || state == KeyState.fresh;
}

bool isFresh(KeyState state)
{
    return state == KeyState.fresh;
}

bool isUp(KeyState state)
{
    return state == KeyState.up || state == KeyState.released;
}

bool isReleased(KeyState state)
{
    return state == KeyState.released;
}

