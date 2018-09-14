module magra.gameloop;

import derelict.glfw3;
import std.exception;
import magra.globals;
import magra.time;
import magra.renderer;

class GameLoop
{
    bool quitting = false;

    //Whether or not rendering is enabled this frame.
    private bool renderingEnabled = true;
    
    float tickRate = 30.0;
    void function() preTick = null;
    void function() postTick = null;
    //void function(SDL_Event) eventHandler = null;
    
    void run()
    {
        auto startTime = currentTimeMS();
        
        for(int gameTick = 1; !quitting; gameTick++)
        {
            auto goalTime = startTime + (gameTick * (1000 / tickRate));
            
            //Update the mouse and keyboard.
            mouse.update();
            keyboard.update();
            
            //Process any events caught by GLFW
            glfwPollEvents();

            //If we've already missed the frame deadline before the game logic
            //runs, disable rendering so we can try and catch up.
            if(gameTick != 1 && currentTimeMS() > goalTime)
                renderingEnabled = false;
            
            runGameTick();
                
            //Render the game scene, if we're not behind.
            if(renderingEnabled)
                renderingQueue.drawLayers();
                
            renderingQueue.clearLayers();
            
            //Wait for goal time.
            auto timeToWait = goalTime - currentTimeMS();
            
            if(timeToWait > 0)
                delayMS(cast(long) timeToWait);
                
            //Flip the display.
            if(renderingEnabled)
                glfwSwapBuffers(window);

            renderingEnabled = true;
        }
    }

    void runGameTick()
    {
        if(preTick !is null)
            preTick();
                
        actors.tick();
                
        if(postTick !is null)
            postTick();
    }

    bool renderingIsEnabled()
    {
        return renderingEnabled;
    }
}

