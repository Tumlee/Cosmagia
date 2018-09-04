module magra.init;

import std.exception;
import std.string;

import magra.base;

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
        //Load up Derelict.
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        DerelictSDL2Mixer.load();

        //Initialize global Magra classes.
        canvas = new Canvas;
        mouse = new Mouse;
        keyboard = new Keyboard;
        actors = new ActorList;
        gameLoop = new GameLoop;
        
        auto windowFlags = SDL_WINDOW_OPENGL;
        
        if(fullscreen)
            windowFlags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
        
        //Create the SDL window and renderer.
        window = SDL_CreateWindow(  windowTitle.toStringz,
                                    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                    screenWidth, screenHeight,
                                    windowFlags);
                                                                                    
        renderer = SDL_CreateRenderer(window, -1, 0);
        enforce(renderer, "Failed to set up an SDL renderer.");
        
        SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "Bilinear");
        SDL_RenderSetLogicalSize(renderer, screenWidth, screenHeight);

        canvas.targetRenderer = renderer;
        
        IMG_Init(IMG_INIT_PNG);
        
        //Set up sound.
	    enforce(Mix_OpenAudio(soundSampleRate, AUDIO_S16SYS, 2, soundBufferSize) == 0,
	            "Failed to initialize audio mixer.");
	            
	    Mix_AllocateChannels(soundChannels);
	    Mix_Volume(-1, MIX_MAX_VOLUME);
    }
}
