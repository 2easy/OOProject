#include <SDL.h>
#include "SDL_audio.h"
#include "constants.h"
#include "engine.h"
#include "video.h"
#include "sound.h"

SDL_Surface *screen = NULL;
SDL_Event event;
SDL_Rect ground[4], background_dest;
int map[31][30];
int n = 23, m = 15, have_powerup = 0;

int main(int argc, char *args[]) {
	Uint8 * keystate = SDL_GetKeyState(NULL);
	pacman_t pacman;
	ghost_t ghosts[4];
	int i, j;
	int direction = NONE;
	int lifes_left = PACMAN_MAX_LIFES;
	unsigned int score = 0, level = 1, done = 0, flag = 1;
	srand(time(NULL));
	/*SDL initialization*/
	if ((screen = SDL_SetVideoMode(875,775,32,SDL_SWSURFACE|SDL_DOUBLEBUF|SDL_FULLSCREEN)) == NULL) {
		fprintf(stderr, "Couldn't initialize SDL: %s\n", SDL_GetError());
		exit(1);
	}
	if (SDL_Init(SDL_INIT_AUDIO) < 0) {
		fprintf(stderr, "Couldn't initialize SDL: %s\n", SDL_GetError());
		SDL_Quit();
		exit(1);
	}
	/*Bitmaps initialization*/
	load_bitmaps();
	/*Cutting bitmaps to rectangles arrays*/
	init_bitmap_rect(pacman.animation, &pacman.position, 5);
	init_bitmap_rect(ghosts[0].animation, &ghosts[0].position, 2);
	init_bitmap_rect(ghosts[1].animation, &ghosts[1].position, 2);
	init_bitmap_rect(ghosts[2].animation, &ghosts[2].position, 2);
	init_bitmap_rect(ghosts[3].animation, &ghosts[3].position, 2);
	init_bitmap_rect(ground, &background_dest, 3);
	/*Setup audio mode*/
	Mix_OpenAudio(22050, AUDIO_S16SYS, 2, 640);
	/*Load Sounds*/
	load_sounds();
	/*Last preparations*/
	map_init(map);
	font_init();
	characters_init(&pacman, ghosts, &direction, &background_dest);
	draw(&pacman, ghosts);
	draw_lifes(&pacman, lifes_left);
	draw_score(score);
	draw_level(level);
	SDL_Flip(screen);
	/*Let's the game begin*/
	Mix_PlayChannel(-1, theme, 0);
	SDL_Delay(4250);
	while(!done) {
		int collision;
		pacman.speed = PACMAN_SPEED;
		/*Slow down eating pacman*/
		if (pacman.slow) {
			pacman.slow--;
			pacman.speed = PACMAN_SPEED - 1;
		}
		/*Move pacman*/
		for (i = 0; i < pacman.speed; i++) {
			move_pacman(&pacman, direction, &score);
		}
		bring_ghosts_morale_back(ghosts);
		/*Weaken ghosts if got POWERUP*/
		if (have_powerup) {
			Mix_PlayChannel(-1, killmode, 3);
			for (i = 0; i < 4; i++) {
				if (ghosts[i].weakness_state != DEAD) {
					ghosts[i].weakness_state = WEAK;
					ghosts[i].time_to_recover = TIME_TO_RECOVER;
				}
			}
			have_powerup = 0;
		}
		/*Slow the ghosts down if they are weak*/
		for (i = 0; i < 4; i++) {
			int state = ghosts[i].weakness_state;
			if (state == WEAK || state == FLASHING) {
				ghosts[i].speed = GHOST_SPEED - 2;
			}
			if (state == TELEPORTED) {
				ghosts[i].speed = GHOST_SPEED -1;
			}
		}
		/*Move ghosts around*/
		for (i = 0; i < 4; i++) {
			for (j = 0; j < ghosts[i].speed; j++) {
				move_ghost(ghosts + i, i, &pacman);
			}
		}
		/*Collision detection*/
		collision = ghosts_collision(&pacman, ghosts);
		if (collision != NOT_CAUGHT) {
			if (ghosts[collision].weakness_state == NORMAL) {
				lifes_left--;
				if (!lifes_left) {
					int best = high_score(score);
					if (score == best) {
						printf("Congratulations! You have beaten hiscore!\nScore: %d\n", score);
					} else {
						printf("Game over. You need more practise.\nScore: %d\nHiscore: %d\n", score, best);
					}
					exit(0);
				}
				Mix_PlayChannel(-1, death, 0);
				SDL_Delay(1500);
				characters_init(&pacman, ghosts, &direction, &background_dest);
				draw(&pacman, ghosts);
				draw_lifes(&pacman, lifes_left);
				draw_score(score);
				draw_level(level);
				SDL_Flip(screen);
				SDL_Delay(1000);
			} else if (ghosts[collision].weakness_state == WEAK || ghosts[collision].weakness_state == FLASHING) {
				Mix_PlayChannel(-1, chompaghost, 0);
				SDL_Delay(600);
				ghosts[collision].weakness_state = DEAD;
				score += 400;
			}
		}
		/*Extra life*/
		if (score >= 10000 && flag) {
			flag = 0;
			lifes_left++;
		}
		/*Next level*/
		if (!pills_left()) {
			level++;
			map_init(map);
			characters_init(&pacman, ghosts, &direction, &background_dest);
			draw(&pacman, ghosts);
			draw_lifes(&pacman, lifes_left);
			draw_score(score);
			draw_level(level);
			SDL_Flip(screen);
			Mix_PlayChannel(-1, newlevel, 0);
			SDL_Delay(1000);
		} else {
			draw(&pacman, ghosts);
			draw_lifes(&pacman, lifes_left);
			draw_score(score);
			draw_level(level);
			SDL_Flip(screen);
		}
		/*Detecting player signals*/
		while(SDL_PollEvent(&event)) {
			if(event.type == SDL_QUIT)
				done = 1;
			if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)
				done = 1;
		}
		if (keystate[SDLK_RIGHT]) {
			direction = RIGHT;
		} else if (keystate[SDLK_LEFT]) {
			direction = LEFT;
		} else if (keystate[SDLK_UP]) {
			direction = UP;
		} else if (keystate[SDLK_DOWN]) {
			direction = DOWN;
		} else {
			direction = NONE;
		}
	}
	/*Freeing sounds*/
	free_sounds();
	/*Freeing surfaces*/
	free_surfaces();
	SDL_Quit();
	return 0;
}
