module magra.gameloop;

import derelict.sdl2.sdl;
import std.exception;
import magra.globals;

class GameLoop
{
    bool quitting = false;
    
    float tickRate = 30.0;
    void function() preTick = null;
    void function() postTick = null;
    void function(SDL_Event) eventHandler = null;
    
    void run()
    {
        auto startTime = SDL_GetTicks();
        
        for(int gameTick = 1; !quitting; gameTick++)
        {
            auto goalTime = startTime + (gameTick * (1000 / tickRate));
            
            //Update the mouse and keyboard.
            mouse.update();
            keyboard.update();
            
            //Process all events and send them to the appropriate place.
            SDL_Event event;

            while(SDL_PollEvent(&event))
            {
                //Pass this event to the mouse and keyboard
                //to see if it's anything they can handle.
                keyboard.handleEvent(event);
                mouse.handleEvent(event);

                if(eventHandler !is null)
                    eventHandler(event);
            }
            
            //Run the game logic
            if(preTick !is null)
                preTick();
                
            actors.tick();
                
            if(postTick !is null)
                postTick();
                
            //Re-enable the canvas so it doesn't get stuck.
            canvas.enabled = true;
            
            //Render the game scene, if we're not behind.
            if(goalTime > SDL_GetTicks())
            {
                canvas.draw();
                canvas.clear();
            }
            
            //Wait for goal time.
            auto timeToWait = goalTime - SDL_GetTicks();
            
            if(timeToWait > 0)
            {
                SDL_Delay(cast(uint) timeToWait);
                
                //Flip the display.
                SDL_RenderPresent(renderer);
            }
            else
            {
                //Disable rendering to all layers for the next tic.
                canvas.enabled = false;
            }
        }
    }
}

