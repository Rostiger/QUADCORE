class Menu {
	
	boolean active = true;
	int alpha;
	int userId;
	PImage bg;

	Input input;

	// variables for the zamSpielen logo
	PVector lg1Pos, lg1Siz;
	float lg1Scl, lg1Rot, lg1Ratio;

	// pulser
	Pulser pulser = new Pulser();

	Menu() {
		alpha = 255;
		userId = 1;
		setUser(userId);

		lg1Pos = new PVector();
		lg1Scl = 1;	
		lg1Rot = 0;	
	}

	void update() {
		// handle the pause menu
		if (gManager.paused) {

		} else {
		// handle the main menu
			// set the size and position of the zamSpielen logo
			if (lg1Siz == null) {
				lg1Siz = new PVector( lg1.width, lg1.height);	
				lg1Ratio = lg1Siz.y / lg1Siz.x;
				lg1Siz.x = WIN_WIDTH * 0.5;
				lg1Siz.y = lg1Ratio * lg1Siz.x;
				lg1Pos.y = -WIN_HEIGHT / 2;
			}
			lg1Scl = pulser.pulse( 1.0, 1.05, 0.4, 2.0 );
			lg1Pos.x = -lg1Siz.x * lg1Scl / 2;
		}

		// draw the menu
		draw();

		//take care of inputs
		input.update();
		if (input.startReleased) {
			gManager.paused = false;
			active = false;
		}
	}

	void draw() {
		// draw the background image
		noStroke();

		if (gManager.paused) {
			fill(0,0,0,100);
			image( bg, 0, 0 );
		} else fill(0,0,0,255);

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
		image( lg1, lg1Pos.x, lg1Pos.y, lg1Siz.x * lg1Scl, lg1Siz.y * lg1Scl );
		textAlign(CENTER);		
		textSize(FONT_SIZE);
		text( "PRESENTS", 0, lg1Pos.y + lg1Siz.y );
		text( "START GAME", 0, 0 );
		text( "HOW TO PLAY", 0, FONT_SIZE );
		text( "ABOUT", 0, FONT_SIZE * 2 );
	}

	void drawPauseMenu() {
		textAlign(CENTER);
		textSize(FONT_SIZE * 3);
		text("GAME PAUSED",0,-100);
		textSize(FONT_SIZE);
		text( "CONTINUE", 0, 0 );
		text( "HOW TO PLAY", 0, FONT_SIZE );
		text( "EXIT", 0, FONT_SIZE * 2 );
	}

	void setUser(int _id) {
		input = new Input(_id);
		userId = _id;
	}

	void keyPressed()  { input.keyPressed(); }
	void keyReleased() { input.keyReleased(); }

}