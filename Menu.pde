class Menu {
	
	boolean active = true;
	boolean tutorial = false;
	boolean credits = false;
	boolean settings = false;
	int bgColor = colors.bg;
	int prevColorScheme = 0;
	int alpha;
	int userId;
	PImage bg;
	float borderWeight, borderScale;
	float volumeSfx, volumeMsc;

	ArrayList < Input > input;

	// menus
	String[] pauseMenu = new String[]{"CONTINUE","SETTINGS","RESTART","HOW TO PLAY","EXIT"};
	String[] mainMenu = new String[]{"START GAME","SETTINGS","HOW TO PLAY","ABOUT"};
	String[] backMenu = new String[]{"BACK"};
	String[] settingsMenu = new String[]{"SFX VOLUME", "MUSIC VOLUME", "TOP_VIEW", "SHADERS", "COLOR_SCHEME"};
	int selectedItem, selectedSetting;
	float itemFontScale;

	// components
	Grid grid = new Grid();
	Pulser pulser1 = new Pulser();

	Menu() {
		alpha = 255;
		userId = (int)floor(random(0,4));

		selectedItem = 0;
		selectedSetting = 0;
		itemFontScale = 1;

		volumeSfx = 0.8;
		volumeMsc = 0.8;

		input = new ArrayList();
		for (int i=0; i<4; i++) {
			Input in = new Input(i);
			input.add(in);
		}

		borderWeight = ARENA_BORDER * 1.35;
		borderScale = 2;
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
		if (!tutorial && !credits && !settings) {
			if (gManager.paused) {
				if (input.get(userId).shootReleased) {
					switch( selectedItem ) {
						case 0: // CONTINUE 
							active = false;
							gManager.paused = false;
						break;
						case 1: settings = true; break;
						case 2: // RESTART
							active = false;
							gManager.paused = false;
							gManager.gameOver = true;
							gManager.reset();
						break;
						case 3: // HOW TO PLAY
							tutorial = true;
						break;
						case 4: // EXIT
							gManager.paused = false;
						break;
					}
					selectedItem = 0;
				}
			} else {
			// handle the main menu
				if (input.get(userId).shootReleased) {
					switch( selectedItem ) {
						case 0: // START GAME
							active = false; 
							gManager.reset();
						break;
						case 1: settings = true; break;
						case 2: tutorial = true; break;
						case 3: credits = true; break;
					}
					selectedItem = 0;
				}
			}
		} else {

			// handle the settings screen
			if (settings) {
				switch (selectedSetting) {
					case 0: volumeSfx = moveSlider(volumeSfx, 0.0, 1.0, 0.1); break;
					case 1: volumeMsc = moveSlider(volumeMsc, 0.0, 1.0, 0.1); break;
					case 2: TOP_VIEW = toggleBool(TOP_VIEW); break;
					case 3: SHADERS = toggleBool(SHADERS); break;
					case 4: 
						COLOR_SCHEME = browseList(colors.colorSchemes, COLOR_SCHEME); 
						if (COLOR_SCHEME != prevColorScheme) {
							colors.pickColorScheme(COLOR_SCHEME);
							prevColorScheme = COLOR_SCHEME;
							bgColor = colors.bg;
						}
					break;
				}
			}

			// exit the submenu
			if (input.get(userId).shootReleased) {
				tutorial = false;
				credits = false;
				settings = false;
			}
		}
	}

	float moveSlider(float _value, float _minRange, float _maxRange, float _step) {
		// moves a value between a range
		float value = _value;

		if (input.get(userId).rightReleased) {
			if (value < _maxRange) value += _step;
			else value = _maxRange;
		}
		
		if (input.get(userId).leftReleased) {
			if (value > _minRange) value -= _step;
			else value = _minRange;
		}

		if (value < _minRange) value = _minRange;
		if (value > _maxRange) value = _maxRange;

		return value;
	}

	boolean toggleBool(boolean _bool) {
		boolean b = _bool;
		if (input.get(userId).rightReleased || input.get(userId).leftReleased) b = !b;
		return b;
	}

	int browseList(String[] _list, int _listItem) {
		// browse horizontal lists
		if (input.get(userId).rightReleased) {
			if (_listItem < _list.length - 1) _listItem++;
			else _listItem = 0;
		}

		if (input.get(userId).leftReleased) {
			if (_listItem > 0) _listItem--;
			else _listItem = _list.length - 1;
		}

		return _listItem;
	}

	void draw() {
		// draw the background
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		
		if (gManager.paused) {
			imageMode(CENTER);
			image(bg,0,0);
			alpha = 75; 
		} else alpha = 255;

		// draw a background rectangle
		fill(bgColor,alpha);
		stroke(colors.player[userId],255);
		strokeWeight(borderWeight * borderScale);		
		rectMode(CENTER);
		rect(0,0,WIN_HEIGHT,WIN_HEIGHT);

		//rotate the canvas to the player that's using the menu
		if (TOP_VIEW)
		switch (userId) {
			case 0: rotate(radians(180)); break;
			case 1: rotate(radians(0)); break;
			case 2: rotate(radians(270)); break;
			case 3: rotate(radians(90)); break;
		}

		// set positions
		float edgePos = WIN_HEIGHT / 2 - borderWeight;
		PVector posHeadline = new PVector(-edgePos + gridSize * 2, -edgePos + gridSize * 3.5);
		PVector posLogo 	= new PVector(-edgePos + gridSize * 2, -edgePos + gridSize * 4);
		PVector posVersion 	= new PVector( edgePos - gridSize * 1.5, gridSize * 2.5);
		PVector menuPos 	= new PVector( 2, edgePos - gridSize + 5);

		if (!tutorial && !credits && !settings) {
			drawHeadLine(posHeadline, "ZAMSPIELEN PRESENTS");
			drawLogo(posLogo);
			drawVersion(posVersion);

			if (gManager.paused) drawMenu(pauseMenu, menuPos);
			else drawMenu(mainMenu, menuPos);
		}

		PVector gridPos = new PVector(-WIN_HEIGHT / 2 + borderWeight,-WIN_HEIGHT / 2 + borderWeight);
		PVector gridSiz = new PVector(VIEW_WIDTH + gridSize, VIEW_HEIGHT + gridSize);
		// grid (pos, siz, cellSize, pointSize, pointWeight, color, alpha)
		grid.drawGrid(gridPos, gridSiz, gridSize * 4, gridSize , 1, colors.player[userId], 100);
		grid.drawGrid(gridPos, gridSiz, gridSize / 2, gridSize / 8, 1, colors.player[userId], 50);

		if (tutorial || credits || settings) {
			drawSubMenu();
			drawMenu(backMenu, menuPos);
		}

		popMatrix();
	}

	int navigateMenu(String[] _menuName, int _selectedItem) {
		// menu navigation
		if (input.get(userId).downReleased) {
			if (_selectedItem < _menuName.length - 1) _selectedItem++;
			else _selectedItem = 0;
		}

		if (input.get(userId).upReleased) {
			if (_selectedItem > 0) _selectedItem--;
			else _selectedItem = _menuName.length - 1;
		}

		return _selectedItem;
	}

	void drawMenu(String[] _menuName, PVector _pos) {
		selectedItem = navigateMenu(_menuName, selectedItem);
		
		PVector pos = new PVector( _pos.x, _pos.y - gridSize * _menuName.length + gridSize / 2 );
		float hSize = gridSize * 11;
		
		// draw pause text
		if (gManager.paused && !tutorial && !credits && !settings) {
			fill(colors.player[userId],blink.blink(255,0,14));
			textAlign(RIGHT);
			textSize(FONT_SIZE);
			noStroke();
			text("//GAME PAUSED", pos.x, pos.y - gridSize);
		}

		// menu item colors
		int bg1 = 0;
		int bg2 = 0;
		int st1 = 0;
		int st2 = 0;
		int txt = 0;

		rectMode(CENTER);
		strokeWeight(1);
		textAlign(CENTER);
		textSize(FONT_SIZE * 0.8);

		// draws the contents of a spcified menu array
		for (int i = 0; i < _menuName.length; i++) {

			float y = pos.y + gridSize * i;

			if (i == selectedItem) {
				bg1 = colors.bg;
				bg2 = colors.player[userId];
				st1 = colors.player[userId];
				st2 = colors.player[userId];
				txt = colors.player[userId];
			} else {
				bg1 = colors.node2;
				bg2 = colors.bg;
				st1 = colors.player[userId];
				st2 = colors.player[userId];
				txt = colors.player[userId];
			}

			stroke(st1,255);
			fill(bg1,255);
			rect(pos.x, y, hSize, gridSize);

			fill(bg2,255);
			stroke(st2,255);
			rect(pos.x + hSize / 2, y, gridSize, gridSize);
			rect(pos.x - hSize / 2, y, gridSize, gridSize);

			fill(txt,255);
			noStroke();
			text(_menuName[i], pos.x, y + gridSize * 0.25);
		}
	}

	void drawSubMenu() {
		PVector offset = new PVector(-WIN_HEIGHT / 2 + borderWeight + gridSize, -WIN_HEIGHT / 2 + borderWeight + gridSize * 5.5);
		PVector boxSiz = new PVector( WIN_HEIGHT - borderWeight * 2 - gridSize, gridSize * 2);

		rectMode(CORNER);
		fill(colors.player[userId], 255);
		stroke(colors.player[userId], 255);
		rect(offset.x - gridSize * 0.5, offset.y - gridSize * 1.5, boxSiz.x, boxSiz.y );
		
		textSize(FONT_SIZE * 1.5);
		textAlign(LEFT);
		fill(colors.solid);
		String headline = "";
		if (tutorial) headline = "H";
		else if (credits) headline = "C";
		else headline = "S";

		text("//QUADCORE - " + headline, offset.x, offset.y);

		offset.y += gridSize * 2;
		fill(colors.solid, 200);
		rect(offset.x - gridSize * 0.5, offset.y - gridSize * 1.5, boxSiz.x, boxSiz.y * 5);

		fill(colors.player[userId],255);
		noStroke();
		textSize(FONT_SIZE);

		if (tutorial) {

			String[] tutText = new String[]{
				"USE     TO MOVE YOUR QUAD.",
				"PRESS     TO SHOOT.",
				"HOLD     TO CHARGE A SHOT.",
				"PRESS     TO USE ITEMS.",
				"PRESS     TO RESPAWN.",
				"SPAWN ONTO OTHER PLAYERS TO KILL THEM.",
				"RESPAWN TIME INCREASES WITH EACH DEATH.",
				"CAPTURE ALL     TO WIN."
			};

			for (int i=0; i<tutText.length; i++) {

				text(tutText[i],offset.x, offset.y + gridSize * i);
				float iconPos = getSubStringPosition(tutText[i],"     ");
				if (iconPos != -1) {
					String iconType = "";
					switch(i) {
						case 0: iconType = "DPAD"; break;
						case 1: iconType = "BTN3"; break;
						case 2: iconType = "BTN3"; break;
						case 3: iconType = "BTN1"; break;
						case 4: iconType = "BTN3"; break;
						case 7: iconType = "NODE"; break;
					}
					drawIcon(offset.x + iconPos, offset.y + gridSize * i, 1, iconType);
				}
				
			}

		} else if (credits) {

			String[] credText = new String[]{
				"A GAME BY CLEMENS SCOTT OF BROKEN RULES",
				"MADE FOR HANS G. & ZAMSPIELEN",
				" ",
				"CO_PRODUCED BY JOSEF WIESNER",
				"ADDITIONAL LEVELS BY TANJA SCHANTL",
				" ",
				"MADE WITH PROCESSING",
				"BEN FRY | CASEY REAS | DAN SHIFFMAN",
				"SOUND LIBRARY BY DAMIEN DI FEDE",
				"SOUND FX MADE WITH CFXR",
				"GAME PAD LIBRARY BY PETER LAGER"
			};

			textSize(FONT_SIZE * 0.8);

			for (int i=0; i<credText.length; i++) {
				text(credText[i],offset.x, offset.y + gridSize * i * 0.8 - gridSize / 2);
			}

		} else drawSettings(offset);
	}

	void drawSettings(PVector _offset) {
		PVector offset = _offset;
		float optionWidth =  gridSize * 8;
		PVector optionPos = new PVector(offset.x + VIEW_WIDTH / 3, offset.y - FONT_SIZE * 0.8 / 3);

		textSize(FONT_SIZE * 0.8);

		selectedSetting = navigateMenu(settingsMenu, selectedSetting);

		for (int i=0; i<settingsMenu.length; i++) {
			boolean selected = i == selectedSetting ? true : false;
			float y = offset.y + gridSize * i;

			alpha = selected ? 255 : 150;

			fill(colors.player[userId], alpha);
			stroke(colors.player[userId], alpha);
			textAlign(LEFT);
			text(settingsMenu[i], offset.x, y);

			switch (i) {
				case 0: drawSlider	(optionPos.x, optionPos.y, optionWidth, volumeSfx, new PVector(0, 1)); break;
				case 1: drawSlider	(optionPos.x, optionPos.y + gridSize, optionWidth, volumeMsc, new PVector(0, 1)); break;
				case 2: drawBool	(optionPos.x, offset.y + gridSize * 2, optionWidth, TOP_VIEW, selected); break;
				case 3: drawBool	(optionPos.x, offset.y + gridSize * 3, optionWidth, SHADERS, selected); break;
				case 4: drawList	(optionPos.x, offset.y + gridSize * 4, optionWidth, colors.colorSchemes, COLOR_SCHEME, selected); break;
			}
		}
	}

	void drawSlider(float _posX, float _posY, float _siz, float _val, PVector _range) {
		PVector pos = new PVector(_posX, _posY);
		float siz = _siz;
		float val = _val;

		strokeWeight(gridSize * 0.15);
		line(pos.x, pos.y, pos.x + siz, pos.y);

		noStroke();
		float knobPos = map(val, _range.x, _range.y, 0, siz);
		rectMode(CENTER);
		rect(pos.x + knobPos, pos.y, gridSize * 0.7, gridSize * 0.7);
	}

	void drawBool(float _posX, float _posY, float _siz, boolean _bool, boolean _active) {
		PVector pos = new PVector(_posX, _posY);
		String value = _bool ? "TRUE" : "FALSE";
		textAlign(CENTER);
		text(value, pos.x + _siz / 2, pos.y);
		drawSelectors(pos, _siz, _active);
	}

	void drawList(float _posX, float _posY, float _siz, String[] _list, int _listItem, boolean _active) {
		PVector pos = new PVector(_posX, _posY);
		textAlign(CENTER);
		text(_list[_listItem], pos.x + _siz / 2, pos.y);
		drawSelectors(pos, _siz, _active);
	}

	void drawSelectors(PVector _pos, float _siz, boolean _active) {
		PVector pos = _pos;
		float triSiz;
		if (_active && (input.get(userId).leftReleased || input.get(userId).rightReleased)) triSiz = gridSize * 0.5;
		else triSiz = gridSize * 0.3;

		noStroke();
		pos.y -= FONT_SIZE * 0.8 / 3;
		triangle(pos.x, pos.y, pos.x + triSiz, pos.y - triSiz / 2, pos.x + triSiz, pos.y + triSiz / 2);
		triangle(pos.x + _siz, pos.y, pos.x + _siz - triSiz, pos.y - triSiz / 2, pos.x + _siz - triSiz, pos.y + triSiz / 2);
	}

	float getSubStringPosition(String _string, String _searchString) {
		// searches for a given substring within a string and returns its position
		String subString = "";
		float pos = 0;

		for (int i=0; i<_string.length(); i++) {
			if (i == _string.indexOf(_searchString)) {
				subString = _string.substring(0,i);
				pos = textWidth(subString);
				break;
			} else pos = -1;
		}

		return pos;
	}

	void drawLogo(PVector _pos) {
		// draws QUADCORE
		float scl = WIN_SCALE;
		float wght = scl * 4; 
		PVector pos = _pos;
		PVector siz = new PVector(528 * scl, 256 * scl);
		PVector letterSiz = new PVector(siz.x / 4, siz.y / 2);
		int[] verts = new int[]{0,0};
		int[] lines = new int[]{0,0};

		if (!gManager.paused) {
			// draws the grid inside the logo
			// float weight = pulser1.pulse(wght * 0.2, wght * 0.4, 1.0, 0.5, -1);
			float weight = wght * 0.4;
			grid.drawGrid(pos,siz,gridSize / 4, gridSize / 8, 1, colors.player[userId], 255);
			// draw the logo contour
			fill(bgColor,255);
			stroke(bgColor,255);
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
			fill(colors.player[userId],30);
			stroke(colors.player[userId], 255);		
		} else {
			fill(colors.player[userId], 255);		
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

	void drawHeadLine(PVector _pos, String _headline) {
		fill(colors.player[userId]);
		noStroke();
		textSize(FONT_SIZE);
		textAlign(LEFT);
		text(_headline, _pos.x, _pos.y);
	}

	void drawVersion(PVector _pos) {
		fill(colors.player[userId], 255);
		textSize(FONT_SIZE * 0.5);
		textAlign(RIGHT);
		text("V." + version, _pos.x, _pos.y);
	}

	void drawIcon(float _posx, float _posy, float _scale, String _type) {
		PVector pos = new PVector(_posx,_posy);
		float siz = floor(gridSize * _scale);
		PGraphics icon =  createGraphics((int)siz, (int)siz);
		icon.beginDraw();
		icon.fill(colors.player[userId]);
		icon.stroke(colors.player[userId]);
		icon.pushMatrix();
		icon.translate(siz / 2, siz / 2);

		if (_type == "DPAD") {

			for(int i=0;i<4;i++) {
				icon.stroke(colors.player[userId]);
				icon.rotate(radians(90 * i));	
				icon.strokeWeight(siz / 10);
				icon.line(0,0,0,-siz / 8);
				icon.noStroke();
				icon.triangle(0, -siz / 2, -siz / 6, -siz / 4, siz / 6, - siz / 4);
			}

		} else if(_type == "BTN0" || _type == "BTN1" || _type == "BTN2" || _type == "BTN3" ) {

			String no = str(_type.charAt(_type.length() - 1));

			for(int i=0;i<4;i++) {
				if (str(i).equals(no)) icon.fill(colors.player[userId]);
				else {
					icon.noFill();
					icon.stroke(colors.player[userId]);
				}
				icon.rotate(radians(-90 * i));
				icon.ellipse(0, -siz / 4, siz / 4, siz / 4);

			}

		} else if (_type == "NODE") {

			icon.strokeWeight(floor(siz / 4));
			icon.fill(colors.solid);
			icon.rectMode(CENTER);
			icon.rect(0, 0, siz, siz);
			icon.strokeWeight(floor(siz / 8));
			icon.rect(0, 0, siz / 3, siz / 3);

		} else {
			icon.rectMode(CENTER);
			icon.fill(colors.player[userId]);
			icon.noStroke();
			icon.rect(0, 0, siz, siz);
		}
		icon.popMatrix();
		icon.endDraw();
		imageMode(CORNER);
	  	image( icon, pos.x + siz * 0.1, pos.y - siz * 0.8);
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