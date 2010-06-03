void bring_ghosts_morale_back(ghost_t *ghosts) {
	int i;

	for (i = 0; i < 4; i++) {
		if (ghosts[i].weakness_state != DEAD) {
			ghosts[i].time_to_recover--;
			if (ghosts[i].weakness_state == TELEPORTED && ghosts[i].time_to_recover == 0) {
				ghosts[i].weakness_state = NORMAL;
			}
			if (ghosts[i].time_to_recover == (TIME_TO_RECOVER / 3) && ghosts[i].weakness_state == WEAK) {
					ghosts[i].weakness_state = FLASHING;
				} else if (ghosts[i].time_to_recover <= 0 && ghosts[i].weakness_state == FLASHING) {
					ghosts[i].animation_state = 0;
					ghosts[i].weakness_state = NORMAL;
					ghosts[i].time_to_recover = 0;
			}	
		}
		if (ghosts[i].weakness_state == NORMAL || ghosts[i].weakness_state == DEAD) {
			ghosts[i].speed = GHOST_SPEED;
		}
		if (ghosts[i].position.x >= 14 * IMAGE_WIDTH && ghosts[i].position.x <= 15 * IMAGE_WIDTH
		&& ghosts[i].position.y <= 14 * IMAGE_HEIGHT && ghosts[i].position.y >= 13 * IMAGE_HEIGHT) {
			ghosts[i].weakness_state = NORMAL;
		}
	}
}

static int allot_direction(ghost_t *ghost) {
	int directions[4] = {ghost->direction, ghost->direction, ghost->direction, ghost->direction};	
	int x = ghost->position.x / IMAGE_WIDTH;
	int y = ghost->position.y / IMAGE_HEIGHT;
	int i = 0;

	if (map[y][x+1] != WALL && ghost->direction != LEFT) {
		directions[i++] = RIGHT;
	}
	if (map[y][x-1] != WALL && ghost->direction != RIGHT) {
		directions[i++] = LEFT;
	}
	if (map[y-1][x] != WALL && ghost->direction != DOWN) {
		directions[i++] = UP;
	}
	if (map[y+1][x] != WALL && map[y+1][x] != CAGE && ghost->direction != UP) {
		directions[i++] = DOWN;
	}
	return directions[(rand() % i)];
}

static int get_direction_towards(ghost_t *ghost, int n, int m) {
	int directions[4] = {ghost->direction, ghost->direction, ghost->direction, ghost->direction};	
	int x = ghost->position.x / IMAGE_WIDTH;
	int y = ghost->position.y / IMAGE_HEIGHT;
	if (ghost->position.x < m * IMAGE_WIDTH && map[y][x+1] != WALL && ghost->direction != LEFT) {
		return RIGHT;
	} else if (ghost->position.x > m * IMAGE_WIDTH && map[y][x-1] != WALL && ghost->direction != RIGHT) {
		return LEFT;
	} else if (ghost->position.y < n * IMAGE_HEIGHT && map[y+1][x] != WALL && ghost->direction != UP) {
		return DOWN;
	} else if (ghost->position.y > n * IMAGE_HEIGHT && map[y-1][x] != WALL && ghost->direction != DOWN) {
		return UP;
	}
	return allot_direction(ghost);
}

void move_ghost(ghost_t *ghost, int ghost_name, pacman_t *pacman) {
	/*Check if I can change direction*/
	if (ghost->position.x % IMAGE_WIDTH == 0 && ghost->position.y % IMAGE_HEIGHT == 0) {
		/*Get my position*/
		int x = ghost->position.x / IMAGE_WIDTH;
		int y = ghost->position.y / IMAGE_HEIGHT;
		/*If I'm in cage, get out of it*/
		if (ghost->weakness_state != DEAD && map[y][x] == CAGE) {
			if (map[y-1][x] != WALL) {
				ghost->direction = UP;
			} else if (map[y][x-1] != WALL) {
				ghost->direction = LEFT;
			} else {
				ghost->direction = RIGHT;
			}
		} else if (ghost->weakness_state == DEAD) {
			/*Go to cage*/
			ghost->direction = get_direction_towards(ghost, 14, 14);
		} else if (ghost->weakness_state == WEAK || ghost->weakness_state == FLASHING) {
			/*Run away from pacman*/
			ghost->direction = allot_direction(ghost);
		} else {
			if (ghost_name != BLINKY) {
				ghost->direction = allot_direction(ghost);
			} else {
				/*Blinky's tactic*/
				int tactic = rand() % 5;
				if (tactic) {
					int pacman_x = pacman->position.x / IMAGE_WIDTH;
					int pacman_y = pacman->position.y / IMAGE_HEIGHT;
					ghost->direction = get_direction_towards(ghost, pacman_y, pacman_x);
				} else {
					ghost->direction = allot_direction(ghost);
				}
			}
		}
		/*Move within chosen direction*/
		switch (ghost->direction)
		{
			case RIGHT:
				x++;
				break;
			case LEFT:
				x--;
				break;
			case UP:
				y--;
				break;
			case DOWN:
				y++;
				break;
			default:
				printf("Direction %d\n", ghost->direction);
				exit(0);
		}
		if (map[y][x] == TELEPORT) {
			if (ghost->weakness_state == NORMAL) {
				ghost->time_to_recover = AFTER_TELEPORT;
				ghost->weakness_state = TELEPORTED;
			}
			if (x == 29) {
				ghost->position.x = IMAGE_WIDTH * 1;
			} else {
				ghost->position.x = IMAGE_WIDTH * 28;
			}
			return;
		} else if (map[y][x] == WALL) {
			return;
		}
	}
	/*Move sprite*/
	switch (ghost->direction)
	{
		case RIGHT:
			ghost->position.x++;
			break;
		case LEFT:
			ghost->position.x--;
			break;
		case UP:
			ghost->position.y--;
			break;
		case DOWN:
			ghost->position.y++;
			break;
		default:
			printf("Direction %d\n", ghost->direction);
			exit(0);
	}
}

int ghosts_collision(pacman_t *pacman, ghost_t *ghosts) {
	int i;
	/*Check for collision*/
	for (i=0;i<4;i++) {
		if (abs(ghosts[i].position.x-pacman->position.x) < TOLERANCE && abs(ghosts[i].position.y-pacman->position.y) < TOLERANCE) {
			return i;
		}
	}
	return NOT_CAUGHT;
}

int pills_left(void) {
	int i, j, pills = 0;
	/*Check if there is anyting to eat for pacman*/
	for (i = 1; i < 30; i++) {
		for (j = 1; j < 28; j++) {
			if (map[j][i] == PILL) {
				pills++;
			}
		}
	}
	return pills;	
}

unsigned int high_score (unsigned int score) {
	FILE * hisc;
	unsigned int hiscore;
	/*Open high score file*/
	if ((hisc = fopen("high_score", "r+b")) == NULL) {
		fprintf(stderr, "Couldn't open \"high_score\"\n");
		exit(1);
	}
	/*Read current hiscore and check with player score*/
	fread(&hiscore, sizeof (unsigned int), 1, hisc);
	if (score > hiscore) {
		hiscore = score;
		fclose(hisc);
		hisc = fopen("high_score", "w");
		fwrite(&score, sizeof (unsigned int), 1, hisc);
	}
	fclose(hisc);
	return hiscore;
}
