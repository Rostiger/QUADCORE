class Menu {
	
	boolean active = true;
	boolean tutorial = false;
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
						tutorial = true;
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
					case 1:
						tutorial = true;
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
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		
		fill(0,0,0,255);
		stroke(colors.player[userId],255);
		strokeWeight(ARENA_BORDER * 2);		
		rectMode(CENTER);
		rect(0,0,WIN_HEIGHT,WIN_HEIGHT);

		pushMatrix();
		//rotate the canvas to the winner
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}

		if (gManager.paused) drawMenu(pauseMenu);
		else drawMenu(mainMenu);
		if (tutorial) drawTutorial();

		drawLogo(0.8);

		popMatrix();
		if (gManager.paused) {
			imageMode(CENTER);
			tint(255,75);
			image(bg,0,0);
			noTint();
		}

		drawGrid(new PVector(-WIN_WIDTH / 2 + 17,-WIN_HEIGHT / 2 + 2),32);

		popMatrix();
	}

	void drawTutorial() {

	}

	void drawMenu(String[] _menuName) {
		if (gManager.paused) {
			fill(colors.player[userId],255);
			textAlign(CENTER);
			textSize(FONT_SIZE * 3);
			text("GAME PAUSED",0,-VIEW_HEIGHT / 1.2);
		}

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

			pos.y = WIN_HEIGHT / 4 + FONT_SIZE * i;

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

	void setUser(int _id) {
		input = new Input(_id);
		userId = _id;
	}

	void drawLogo(float _scale) {
		// draws QUADCORE
		float scl = _scale;
		float wght = scl * 3;
		PVector siz = new PVector(528 * scl, 256 * scl);
		PVector pos = new PVector(floor(-siz.x / 2), floor(-siz.y / 1.5));
		PVector letterSiz = new PVector(siz.x / 4, siz.y / 2);
		int gridSize = 8;
		int rgb = colors.player[userId];

		while (pos.x % gridSize != 0) pos.x--;
		while (pos.y % gridSize != 0) pos.y--;

		// draws a background rect in pause mode
		// if (gManager.paused) {
		// 	fill(0,0,0,255);
		// 	stroke(0,0,0,255);
		// 	strokeWeight(CELL_SIZE * 2);
		// 	rectMode(CORNER);
		// 	rect(-WIN_WIDTH / 2, pos.y , WIN_WIDTH, siz.y);
		// }

		// draws the grid inside the logo
		noFill();
		stroke(rgb, 50);
		strokeWeight(wght * scl);

		for (float x = pos.x; x < pos.x + siz.x; x += gridSize) {
			line(x, pos.y, x, pos.y + siz.y);
		}

		for (float y = pos.y; y < pos.y + siz.y; y += gridSize) {
			line(pos.x, y, pos.x + siz.x ,y);
		}

		// stores the coordinates of the letters
		int[] verts = new int[]{0,0};
		int[] lines = new int[]{0,0};

		// draw the logo contour
		fill(0,0,0,255);
		stroke(0,0,0,255);
		strokeWeight(wght);
	
		beginShape();
		vertex(pos.x, pos.y);
		vertex(pos.x + siz.x, pos.y);
		vertex(pos.x + siz.x, pos.y + siz.y);
		vertex(pos.x, pos.y + siz.y);

		for (int i=0; i<8; i++){
			verts = getLetter(i);
			beginContour();
			drawLogoLetter(pos, verts, scl, true);
			endContour();
		}
		endShape(CLOSE);

		// draw the letter shapes with outlines
		noFill();
		stroke(rgb, 255);
		strokeWeight(wght);
		for (int i=0; i<8; i++){
			verts = getLetter(i);
			beginShape();
			drawLogoLetter(pos, verts, scl, true);
			endShape();
		}

		// draw non-shape lines of each letter
		for (int i=0; i<8; i++) {
			switch(i) {
				case 0: lines = new int[]{ 64,48, 64,80 }; break;
				case 1: lines = new int[]{ 192,0, 192,32 }; break;
				case 2: lines = new int[]{ 320,128, 320,96, 304,96, 336,96 }; break;
				case 3: lines = new int[]{ 448,48, 448,80 }; break;
				case 4: lines = new int[]{ 112,176, 112,208, 112,192, 144,192 }; break;
				case 5: lines = new int[]{ 208,176, 208,208 }; break;
				case 6: lines = new int[]{ 336,176, 336,208 }; break;
				case 7: lines = new int[]{ 464,176, 464,208 }; break;
			}
			drawLogoLetter(pos, lines, scl, false);
		}
	}

	int[] getLetter(int _letter) {
		int[] verts = new int[]{0,0};
			switch(_letter) {
				case 0: //Q
					verts = new int[]{ 0,0, 128,0, 128,96, 144,96, 128,128, 16,128, 0,112, 0,0, }; break;
				case 1: //U
					verts = new int[]{ 128,0, 256,0, 256,112, 240,128, 128,128, 144,96, 128,96, 128,0 }; break;
				case 2: //A
					verts = new int[]{ 256,16, 272,0, 368,0, 384,16, 384,128, 240,128, 256,112, 256,16, }; break;
				case 3: //D
					verts = new int[]{ 384,0, 480,0, 512,32, 512,128, 384,128, 384,0, 384,0 }; break;
				case 4: //C
					verts = new int[]{ 16,128, 144,128, 144,256, 32,256, 16,240, 16,128 }; break;
				case 5: //O
					verts = new int[]{ 144,128, 256,128, 272,144, 272,256, 160,256, 144,240, 144,128 }; break;
				case 6: //R
					verts = new int[]{ 256,128, 384,128, 400,144, 400,224, 368,224, 400,256, 272,256, 272,144, 256,128 }; break;
				case 7: //E
					verts = new int[]{ 384,128, 528,128, 528,192, 496,224, 528,224, 528,256, 400,256, 368,224, 400,224, 400,144, 384,128 }; break;
			}
			return verts;
	}

	void drawLogoLetter(PVector _pos, int[] _coords, float _scl, boolean _contours) {
		// draws a single logo letter
		float scl = _scl;
		PVector pos = _pos;
		int[] coords = _coords;

		if (_contours) for (int i=0; i<coords.length; i+=2) { vertex( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl ); }
		else for (int i=0; i<coords.length; i+=4){ line( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl, pos.x + coords[i+2] * scl, pos.y + coords[i+3] * scl ); }
	}

	void drawGrid(PVector _offset, int _gridSize){
		noFill();
		strokeWeight(1);
		stroke(colors.player[userId],50);
		int gridSize = _gridSize;
		for (float x=_offset.x; x<WIN_WIDTH; x+=gridSize) {
			line(x,_offset.y,x,WIN_HEIGHT);
		}

		for (float y=_offset.y; y<WIN_HEIGHT; y+=gridSize) {
			line(_offset.x,y,WIN_WIDTH,y);
		}
	}

	void keyPressed()  { 
		for (int i=0; i<4; i++) {
			input.keyPressed(i);
			if (i != userId && (input.upWasPressed || input.downWasPressed)) {
				setUser(i);
				break;
			}
		}
	}

	void keyReleased() { input.keyReleased(userId); }

}