class Menu {
	
	boolean active = true;
	int alpha;
	int userId;
	PImage bg;

	Input input;

	// variables for the zamSpielen logo
	PVector lg1Pos, lg1Siz;
	float lg1Scl, lg1Rot, lg1Ratio;

	// menus
	String[] pauseMenu = new String[]{"CONTINUE","RESTART","HOW TO PLAY","EXIT"};
	String[] mainMenu = new String[]{"START GAME","HOW TO PLAY","ABOUT"};
	int selectedItem;
	float itemFontScale;

	// pulser
	Pulser pulser = new Pulser();

	Menu() {
		alpha = 255;
		userId = 1;
		setUser(userId);

		if (lg1 != null) {
			lg1Pos = new PVector( 0, -WIN_HEIGHT / 2 );
			lg1Siz = new PVector( lg1.width, lg1.height );	

			lg1Ratio = lg1Siz.y / lg1Siz.x;
			lg1Siz.x = WIN_WIDTH * 0.5;
			lg1Siz.y = lg1Ratio * lg1Siz.x;
			lg1Scl = 1;	
			lg1Rot = 0;
		}

		selectedItem = 0;
		itemFontScale = 1;
	}

	void update() {
		// handle the pause menu
		if (gManager.paused) {
			
			if (input.shootReleased) {
				switch( selectedItem ) {
					case 0: // CONTINUE 					
						active = false;
						gManager.paused = false;
					break;
					case 1: // RESTART
						active = false;
						gManager.paused = false;
						gManager.gameOver = true;
						gManager.reset();
					break;
					case 2: // HOW TO PLAY
					break;
					case 3: // EXIT
						gManager.paused = false;
						selectedItem = 0;
					break;
				}
			}

		} else {
		// handle the main menu
			// set the size and position of the zamSpielen logo
			lg1Scl = pulser.pulse( 1.0, 1.05, 0.4, 2.0, true );
			lg1Pos.x = -lg1Siz.x * lg1Scl / 2;

			// 
			if (input.shootReleased) {
				switch( selectedItem ) {
					case 0: // START GAME
						active = false; 
						gManager.reset();
					break;
				}
			}
		}

		// draw the menu
		if (active) {
			draw();
			input.update();
		} else selectedItem = 0;
	}

	void draw() {
		// draw the background
		noStroke();
		if (gManager.paused) {
			fill(0,0,0,180);
			image( bg, 0, 0 );
			rect(0,0,WIN_WIDTH,WIN_HEIGHT);
			checkers.drawCheckers( #000000, 90, 40, 14, new PVector( CELL_SIZE, CELL_SIZE ), 2 );
		} else {
			fill(0,0,0,255);
			rect(0,0,WIN_WIDTH,WIN_HEIGHT);
		}

		pushMatrix();

		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);

		//rotate the canvas to the winner
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}

		if (gManager.paused) drawPauseMenu();
		else drawMainMenu();

		popMatrix();
	}

	void drawMenu(String[] _menuName) {

		if (input.downReleased) {
			if (selectedItem < _menuName.length - 1) selectedItem++;
			else selectedItem = 0;
		}

		if (input.upReleased) {
			if (selectedItem > 0) selectedItem--;
			else selectedItem = _menuName.length - 1;
		}

		PVector pos = new PVector( 0, 0 );

		// draws the contents of a spcified menu array
		for (int i = 0; i < _menuName.length; i++) {

			pos.y = FONT_SIZE * i;

			if (i == selectedItem) {
				alpha = 255;
				itemFontScale = 1.3;
			} else {
				alpha = 100;
				itemFontScale = 1;
			}

			textSize(FONT_SIZE * itemFontScale);
			fill(colors.player[userId],alpha);
			text( _menuName[i], pos.x, pos.y );
		}
	}

	void drawMainMenu() {
		fill(colors.player[userId],255);
		image( lg1, lg1Pos.x, lg1Pos.y, lg1Siz.x * lg1Scl, lg1Siz.y * lg1Scl );
		textAlign(CENTER);		
		textSize(FONT_SIZE);
		text( "PRESENTS", 0, lg1Pos.y + lg1Siz.y );
		drawMenu(mainMenu);
	}

	void drawPauseMenu() {
		fill(colors.player[userId],255);
		textAlign(CENTER);
		textSize(FONT_SIZE * 3);
		text("GAME PAUSED",0,-100);
		drawMenu(pauseMenu);
	}

	void setUser(int _id) {
		input = new Input(_id);
		userId = _id;
	}

	void setupLogo(PImage _logo) {
	}

	void keyPressed()  { input.keyPressed(); }
	void keyReleased() { input.keyReleased(); }

}