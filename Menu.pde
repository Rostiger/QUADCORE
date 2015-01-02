class Menu {
	
	boolean active = true;
	boolean tutorial = false;
	int alpha;
	int userId;
	PImage bg;

	ArrayList < Input > input;
	float gridSize;
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
		userId = (int)floor(random(0,4));
		

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

		input = new ArrayList();
		for (int i=0; i<4; i++) {
			Input in = new Input(i);
			input.add(in);
		}

		gridSize = 32 * WIN_SCALE;
	}

	void setUser(int _id) {
		userId = _id;
	}
	
	void update() {
		if (active) {

			// check input
			for (Input i : input) {
				input.get(i.id).update();
				if (i.anyKeyPressed && i.id != userId)  {
					setUser(i.id);
					break;
				}
			}
			
			draw();

		} else selectedItem = 0;

		// handle the pause menu
		if (gManager.paused) {
			if (input.get(userId).shootReleased) {
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
			if (input.get(userId).shootReleased) {
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
	}

	void draw() {
		// draw the background
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		
		fill(colors.solid,255);
		stroke(colors.player[userId],255);
		strokeWeight(ARENA_BORDER * 2);		
		rectMode(CENTER);
		rect(0,0,WIN_HEIGHT,WIN_HEIGHT);

		if (gManager.paused) {
			imageMode(CENTER);
			tint(255,100);
			image(bg,0,0);
			noTint();
		}

		pushMatrix();
		//rotate the canvas to the winner
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}
		drawLogo();

		if (gManager.paused) drawMenu(pauseMenu);
		else drawMenu(mainMenu);
		if (tutorial) drawTutorial();

		noFill();
		PVector gridPos = new PVector(-WIN_HEIGHT / 2 + ARENA_BORDER,-WIN_HEIGHT / 2 + ARENA_BORDER);
		PVector gridSiz = new PVector(VIEW_WIDTH + gridSize, VIEW_HEIGHT + gridSize);
		stroke(colors.player[userId],100);
		drawGrid(gridPos, gridSiz, gridSize * 4, gridSize ,1);
		stroke(colors.player[userId],50);
		drawGrid(gridPos, gridSiz, gridSize / 2, gridSize / 8,1);

		popMatrix();

		popMatrix();
	}

	void drawTutorial() {

	}

	void drawMenu(String[] _menuName) {
		if (gManager.paused) {
			fill(colors.player[userId],255);
			textAlign(CENTER);
			textSize(FONT_SIZE * 3);
			text("GAME PAUSED",0,-VIEW_HEIGHT * 0.35);
		}

		if (input.get(userId).downReleased) {
			if (selectedItem < _menuName.length - 1) selectedItem++;
			else selectedItem = 0;
		}

		if (input.get(userId).upReleased) {
			if (selectedItem > 0) selectedItem--;
			else selectedItem = _menuName.length - 1;
		}

		PVector pos = new PVector( WIN_HEIGHT / 2 - ARENA_BORDER - gridSize * 2 - 1, WIN_HEIGHT / 2 - ARENA_BORDER - gridSize * 5 - 1 );
		float hSize = -gridSize;
		int txt = 0;
		int bg = 0;
		int st = 0;

		// draws the contents of a spcified menu array
		for (int i = 0; i < _menuName.length; i++) {

			float y = pos.y + gridSize * i;

			if (i == selectedItem) {
				alpha = 255;
				hSize = -gridSize * 8;
				bg = colors.player[userId];
				txt = colors.solid;
				st = colors.solid;
			} else {
				alpha = 255;
				hSize = -gridSize * 7;
				bg = colors.bg;
				txt = colors.player[userId];
				st = colors.solid;
			}
			rectMode(CORNER);
			strokeWeight(1);
			stroke(st,255);
			fill(bg,255);
			rect(pos.x,y,hSize, gridSize);
			textAlign(RIGHT);
			textSize(FONT_SIZE);
			fill(txt,255);
			text( _menuName[i], pos.x - gridSize / 4, y + gridSize / 1.2 );
			fill(colors.player[userId]);
			rect(pos.x,y,gridSize,gridSize);
		}
	}

	void drawLogo() {
		// draws QUADCORE
		float scl = WIN_SCALE;
		float wght = scl * 4;
		PVector siz = new PVector(528 * scl, 256 * scl);
		PVector pos = new PVector(-WIN_HEIGHT / 2 + ARENA_BORDER + gridSize * 2,-WIN_HEIGHT / 2 + ARENA_BORDER + gridSize * 4);
		PVector letterSiz = new PVector(siz.x / 4, siz.y / 2);
		int rgb = colors.player[userId];
		int[] verts = new int[]{0,0};
		int[] lines = new int[]{0,0};

		if (!gManager.paused) {
			// draws the grid inside the logo
			noFill();
			stroke(rgb, 255);
			strokeWeight(wght * 0.4);

			drawGrid(pos,siz,gridSize / 4,gridSize / 8,1);


			// draw the logo contour
			fill(colors.solid,255);
			stroke(colors.solid,255);
			strokeWeight(wght * 2);
		
			beginShape();
			vertex(pos.x, pos.y);
			vertex(pos.x + siz.x, pos.y);
			vertex(pos.x + siz.x, pos.y + siz.y);
			vertex(pos.x, pos.y + siz.y);

			for (int i=0; i<8; i++){
				verts = getLetterVerts(i);
				beginContour();
				drawLogoLetter(pos, verts, scl, true);
				endContour();
			}
			endShape(CLOSE);
			fill(rgb,30);
			stroke(rgb, 255);		
		} else {
			fill(rgb, 255);		
			stroke(colors.solid,255);
		}

		strokeWeight(wght);
		// draw the letter shapes with outlines
		for (int i=0; i<8; i++){
			verts = getLetterVerts(i);
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

	int[] getLetterVerts(int _letter) {
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

		if (_contours) {
			strokeCap(PROJECT);
			for (int i=0; i<coords.length; i+=2) { vertex( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl ); }
		} else {
			strokeCap(SQUARE);
			for (int i=0; i<coords.length; i+=4){ line( pos.x + coords[i] * scl, pos.y + coords[i+1] * scl, pos.x + coords[i+2] * scl, pos.y + coords[i+3] * scl ); }
		}
	}

	void drawGrid(PVector _pos, PVector _siz, float _cellSize, float _pointSize, float _pointWeight){
		PVector pos = _pos;
		PVector siz = _siz;
		float cellSize = _cellSize;

		for (float x=0; x<=siz.x; x+=cellSize) {

			for (float y=0; y<=siz.y; y+=cellSize) {
			  drawGridPoint(pos.x + x, pos.y + y, _pointSize, _pointWeight);
			}

		}
	}

	void drawGridPoint(float _x, float _y, float _size, float _weight) {
		PVector pos = new PVector(_x,_y);
		float siz = _size;
		strokeWeight(_weight);
		line(pos.x - siz / 2, pos.y, pos.x + siz / 2, pos.y);
		line(pos.x, pos.y - siz / 2, pos.x, pos.y + siz / 2);
	}

	void keyPressed()  {
		if (active) {
			for (Input i : input) i.keyPressed();
		}
	}

	void keyReleased() { 
		if (active) {
			for (Input i : input) i.keyReleased();
		}
	}

}