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
