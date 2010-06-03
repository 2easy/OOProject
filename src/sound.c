#include"sound.h"
#include "SDL_mixer.h"

Mix_Chunk *theme, *chompadot, *chompaghost, *death, *hit, *newlevel, *killmode;

void load_sounds(void) {
	theme = Mix_LoadWAV("../sounds/theme.wav");
	chompadot = Mix_LoadWAV("../sounds/chompadot.wav");
	chompaghost = Mix_LoadWAV("../sounds/chompaghost.wav");
	death = Mix_LoadWAV("../sounds/death.wav");
	hit = Mix_LoadWAV("../sounds/hit.wav");
	newlevel = Mix_LoadWAV("../sounds/newlevel.wav");
	killmode = Mix_LoadWAV("../sounds/killmode.wav");
}

void free_sounds(void) {
	Mix_FreeChunk(theme);
	Mix_FreeChunk(chompadot);
	Mix_FreeChunk(chompaghost);
	Mix_FreeChunk(death);
	Mix_FreeChunk(hit);
	Mix_FreeChunk(newlevel);
	Mix_FreeChunk(killmode);
}
