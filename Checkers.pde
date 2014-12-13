class Checkers {

	int switchTime, switchDuration, alpha, alpha1, alpha2;
		
	Checkers() {

		switchDuration = 30;
		switchTime = switchDuration;
		alpha1 = 90;
		alpha2 = 40;
		alpha = alpha1;
	
	}

	void drawCheckers() {
		
		if (switchTime > 0) switchTime--;
		else {

			if (alpha1 == 90) alpha1 = 40;
			else alpha1 = 90;

			if (alpha2 == 40) alpha2 = 90;
			else alpha2 = 40;

			switchTime = switchDuration;
		}
		
		alpha = alpha2;

		for (float x = 0; x < VIEW_WIDTH; x += CELL_SIZE * 2) {
			for (float y = 0; y < VIEW_HEIGHT; y += CELL_SIZE * 2) {

				if (alpha == alpha2) alpha = alpha1;
				else alpha = alpha2;

				canvas.rectMode(CORNER);
				canvas.fill(colors.player[gManager.winnerID],alpha);
				canvas.noStroke();
				canvas.rect(x,y,CELL_SIZE * 2,CELL_SIZE * 2);
			}
		}
	}
}