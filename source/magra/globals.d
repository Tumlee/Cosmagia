module magra.globals;

import derelict.sdl2.sdl;

import magra.canvas;
import magra.input;
import magra.actorlist;
import magra.gameloop;

Canvas canvas;
Mouse mouse;
Keyboard keyboard;
ActorList actors;
GameLoop gameLoop;

SDL_Renderer* renderer;
SDL_Window* window;

