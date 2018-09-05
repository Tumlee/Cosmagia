module magra.callbacks;

import derelict.glfw3.glfw3;
import derelict.opengl;
import magra.renderer;
import magra.globals;

import std.stdio;   //FIXME: PLACEHOLDER ONLY

//Because we cannot throw out of an function like the kind that GLFW can call, we
//instead store the Exception and immediately handle it as soon as a callback returns.
Exception storedException = null;

void initCallbacks(GLFWwindow* window)
{
    glfwSetKeyCallback(window, &keyCallback);
    glfwSetCursorPosCallback(window, &cursorPosCallback);
    glfwSetMouseButtonCallback(window, &mouseButtonCallback);
    glfwSetWindowSizeCallback(window, &windowSizeCallback);
}

//GFLW callbacks...
extern (C) nothrow
{
    void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
    {
        try
        {
            if(action == GLFW_PRESS)
                keyboard.pressKey(key);

            if(action == GLFW_RELEASE)
                keyboard.releaseKey(key);
        }
        catch(Exception e)
        {
            storedException = e;
            return;
        }
    }

    void cursorPosCallback(GLFWwindow* window, double xpos, double ypos)
    {
        try
        {
            //Match OpenGL's convention of making the screen go -1.0 -> 1.0
            //Rather than 0 -> screen(width/height)
            //Don't forget that y coordinate is flipped in OpenGL
            double mpx = (xpos * 2 / screenwidth) - 1;
            double mpy = 1 - (ypos * 2 / screenheight);
            
            mouse.move(mpx, mpy);
        }
        catch(Exception e)
        {
            storedException = e;
            return;
        }
    }

    void mouseButtonCallback(GLFWwindow* window, int button, int action, int mods)
    {
        try
        {
            if(action == GLFW_PRESS)
                mouse.pressButton(button);

            if(action == GLFW_RELEASE)
                mouse.releaseButton(button);
            //mouseButtonState[button] = action;
        }
        catch(Exception e)
        {
            storedException = e;
            return;
        }
    }

    void windowSizeCallback(GLFWwindow* window, int width, int height)
    {
        try
        {
            screenwidth = width;
            screenheight = height;
            writefln("Window size callback: %d x %d", width, height);
            glViewport(0, 0, width, height);
        }
        catch(Exception e)
        {
            storedException = e;
            return;
        }
    }

    void glfwErrorCallback(int errorCode, const char* msg)
    {
        try
        {
            import std.stdio;
            import std.conv;
            writeln("GLFW threw the following error:");
            writeln(msg.to!string);
        }
        catch(Exception)
        {
        }
    }

}

