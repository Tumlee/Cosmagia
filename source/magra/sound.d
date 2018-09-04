module magra.sound;

import derelict.sdl2.mixer;

float musicVolume = 1.0;
float soundVolume = 1.0;

void playMusic(Mix_Music* music)
{
    if(music == null)
        return;

    Mix_PlayMusic(music, -1);
}

void playSound(Mix_Chunk* sfx, float pan, float volume)
{
    if(sfx == null)
        return;

	auto channel = Mix_PlayChannel(-1, sfx, 0);

	if(channel != -1)	//Do all the channel panning and volume control.
	{
		if(pan < 0.0)
		    pan = 0.0;
		    
	    if(pan > 1.0)
	        pan = 1.0;
		
		Mix_SetPanning(channel, cast(ubyte) (255 * (1.0 - pan)), cast(ubyte) (255 * pan));
		Mix_Volume(channel, cast(int) (MIX_MAX_VOLUME * volume * soundVolume));
	}

	return;    
}

void stopMusic()
{
    Mix_HaltMusic();
}
