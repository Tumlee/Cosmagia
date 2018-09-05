module magra.init;

import std.exception;
import std.string;

import magra.base;
import magra.renderer;
import magra.callbacks;

class InitSettings
{
    int screenWidth = 640;
    int screenHeight = 480;
    bool fullscreen = false;
    
    string windowTitle = "Magra Game";

    int soundChannels = 32;
    int soundSampleRate = 44100;
    int soundBufferSize = 1024;

    void initializeEngine()
    {
        initGLContext(fullscreen, screenWidth, screenHeight);
        initCallbacks(window);

        //Initialize global Magra classes.
        mouse = new Mouse;
        keyboard = new Keyboard;
        actors = new ActorList;
        renderingQueue = new RenderingQueue;
        gameLoop = new GameLoop;
        
        //Set up sound.
	    /*enforce(Mix_OpenAudio(soundSampleRate, AUDIO_S16SYS, 2, soundBufferSize) == 0,
	            "Failed to initialize audio mixer.");*/
	            
	    /*Mix_AllocateChannels(soundChannels);
	    Mix_Volume(-1, MIX_MAX_VOLUME);*/
    }
}
