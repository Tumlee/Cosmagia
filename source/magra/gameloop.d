module magra.gameloop;

import derelict.glfw3;
import std.exception;
import magra.globals;
import magra.time;
import magra.renderer;

class GameLoop
{
    bool quitting = false;
    
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
            
            //Run the game logic
            if(preTick !is null)
                preTick();
                
            actors.tick();
                
            if(postTick !is null)
                postTick();
                
            //Render the game scene, if we're not behind.
            if(goalTime > currentTimeMS())
                renderingQueue.drawLayers();
                
            renderingQueue.clearLayers();
            
            //Wait for goal time.
            auto timeToWait = goalTime - currentTimeMS();
            
            if(timeToWait > 0)
            {
                delayMS(cast(long) timeToWait);
                
                //Flip the display.
                glfwSwapBuffers(window);
            }
        }
    }
}

