void draw_lifes(pacman_t *pacman, int lifes_left) {
	int i;
	int x, y;
	SDL_Rect lifes_dest;
	lifes_dest.w = IMAGE_WIDTH;
	lifes_dest.h = IMAGE_HEIGHT;
	lifes_dest.y = 2 * IMAGE_HEIGHT;
	for (i = 0; i < lifes_left; i ++) {
		lifes_dest.x = (30 + i) * IMAGE_WIDTH;
		SDL_BlitSurface(pacman_pic[LEFT], &pacman->animation[4], screen, &lifes_dest);
	}
}

void font_init (void) {
	TTF_Init();
	font = TTF_OpenFont("../images/arial.ttf", 20);
	fColor.r = fColor.g = fColor.b = 245;
}

void draw_int(int value) {
	char score_str[15];
	sprintf(score_str, "%d", value); 
	score_pic = TTF_RenderText_Solid(font, score_str, fColor);
	SDL_BlitSurface(score_pic, NULL, screen, &txt_rect);
}

void draw_score(int score) {
	txt_rect.x = 30 * IMAGE_WIDTH;
	txt_rect.y = 4 * IMAGE_HEIGHT;
	draw_int(score);
}

void draw_level(int level) {
	txt_rect.x = 30 * IMAGE_WIDTH;
	txt_rect.y = 6 * IMAGE_HEIGHT;
	draw_int(level);
}
