module magra.gameloop;

import derelict.glfw3;
import std.exception;
import magra.globals;
import magra.time;

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
                
            //Re-enable the canvas so it doesn't get stuck.
            //canvas.enabled = true;
            
            //Render the game scene, if we're not behind.
            if(goalTime > currentTimeMS())
            {
                //canvas.draw();
                //canvas.clear();
            }
            
            //Wait for goal time.
            auto timeToWait = goalTime - currentTimeMS();
            
            if(timeToWait > 0)
            {
                delayMS(cast(long) timeToWait);
                
                //Flip the display.
                //SDL_RenderPresent(renderer);
            }
            else
            {
                //Disable rendering to all layers for the next tic.
                //canvas.enabled = false;
            }
        }
    }
}

