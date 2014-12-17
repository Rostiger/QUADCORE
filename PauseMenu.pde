class PauseMenu {
	
	int alpha;
	int pausedById;

	Input input;

	PauseMenu() {
		alpha = 255;
		input = new Input(0);
	}

	void update() {
		draw();
		input.update();

		if (input.startReleased) {
			gManager.wasPaused = false;
			gManager.paused = false;
		}
	}

	void draw() {
			noStroke();
			fill(0,0,0,100);
			rect(0,0,WIN_WIDTH,WIN_HEIGHT);

			pushMatrix();

			translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);

			//rotate the canvas to the winner
			switch (pausedById) {
				case 0: rotate(radians(180)); break;
				case 1: rotate(radians(0)); break;
				case 2: rotate(radians(270)); break;
				case 3: rotate(radians(90)); break;
			}

			fill(colors.player[pausedById],alpha);
			textAlign(CENTER);
			textSize(FONT_SIZE * 3);
			text("GAME PAUSED",0,-100);

			popMatrix();
	}

	void setId(int _id) {
		input = new Input(_id);
		pausedById = _id;
	}

}