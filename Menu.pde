class Menu {
	
	boolean active = true;
	int alpha;
	int userId;
	PImage bg;

	Input input;

	PVector lg1Pos, lg1Siz;
	float lg1Scl, lg1Rot;

	Menu() {
		alpha = 255;
		userId = 1;
		setUser(userId);

		lg1Pos = new PVector();
		lg1Siz = new PVector();
		lg1Siz.x = WIN_WIDTH * 0.5;
		lg1Siz.y = lg1Siz.x / (lg1.width / lg1.height);
		lg1Pos.x = -lg1Siz.x / 2;
		lg1Pos.y = -lg1Siz.y / 2;
		lg1Scl = 1;		
	}

	void update() {
		//take care of inputs
		input.update();
		if (input.startReleased) active = false;

		// handle the pause menu
		if (gManager.paused) {

		} else {
		// handle the main menu
			lg1Siz.mult(lg1Scl);
		}

		// draw the menu
		draw();
	}

	void draw() {
		// draw the background image
		if (gManager.paused) image( bg, 0, 0 );

		noStroke();
		fill(0,0,0,100);
		rect(0,0,WIN_WIDTH,WIN_HEIGHT);

		pushMatrix();

		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);

		//rotate the canvas to the winner
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}

		fill(colors.player[userId],alpha);

		if (gManager.paused) drawPauseMenu();
		else drawMainMenu();

		popMatrix();
	}

	void drawMainMenu() {
		image( lg1, lg1Pos.x, lg1Pos.y, lg1Siz.x, lg1Siz.y );
	}

	void drawPauseMenu() {
		textAlign(CENTER);
		textSize(FONT_SIZE * 3);
		text("GAME PAUSED",0,-100);
	}

	void setUser(int _id) {
		input = new Input(_id);
		userId = _id;
	}

}