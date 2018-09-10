module magra.input;

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

    void pressKey(int key)
    {
        keys[key] = KeyState.fresh;
    }

    void releaseKey(int key)
    {
        keys[key] = KeyState.released;
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
    //Information about current state of buttons.
    KeyState[int] buttons;

    //Current X and Y position. dx and dy will be provided later.
    double x, y;
    double wheelx = 0;
    double wheely = 0;
    double accWheelx = 0;
    double accWheely = 0;
    //int dx, dy;
    
    void pressButton(int button)
    {
        buttons[button] = KeyState.fresh;
    }

    void releaseButton(int button)
    {
        buttons[button] = KeyState.up;
    }

    void move(double xx, double yy)
    {
        x = xx;
        y = yy;
    }

    void updateWheel(double dx, double dy)
    {
        accWheelx += dx;
        accWheely += dy;
    }
    
    void update()
    {
        //dx = accRelx;
        //dy = accRely;
        wheelx = accWheelx;
        wheely = accWheely;
        //accRelx = 0;
        //accRely = 0;
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

