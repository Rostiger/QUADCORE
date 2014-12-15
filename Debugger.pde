class Debugger {

	float fontSize;

	PVector consolePos;
	PVector consoleSize;
	int 	consoleAlpha;
	boolean consoleActive;

	boolean debugDraw, invincibility, autoShoot;
	int autoShootInterval, autoShootCount;

	DebugOption[] debugOptions = new DebugOption[4];
	int selectedOption;

	Debugger() {
		consoleSize = new PVector(VIEW_WIDTH / 2, WIN_HEIGHT);
		consolePos = new PVector(canvasPos.x - consoleSize.x,0);
		consoleAlpha = 0;
		consoleActive = false;

		debugDraw = false;
		invincibility = false;
		autoShoot = false;

		autoShootInterval = 20;
		autoShootCount = autoShootInterval;
		
		debugOptions[0] = new DebugOption("DEBUG DRAW",false);
		debugOptions[1] = new DebugOption("INVINCIBILITY",false);
		debugOptions[2] = new DebugOption("AUTO FIRE",false);
		debugOptions[3] = new DebugOption("SHOW CHECKERS",false);

		selectedOption = 0;
	}

	void update() {
		if (debugOptions[0].active) debugDraw = true;
		else debugDraw = false;

		if (debugOptions[1].active) invincibility = true;
		else invincibility = false;

		if (debugOptions[2].active) autoShoot = true;
		else autoShoot = false;

		if (debugOptions[3].active) gManager.drawCheckers = true;
		else gManager.drawCheckers = false;
		
		// set the font size
		fontSize = DEBUG_FONT_SIZE;

		// toggle console
		if (gManager.debug) {
			if (!consoleActive) println("Console Activated.");
			consoleActive = true;
			toggleConsole(canvasPos.x - ARENA_BORDER);
		} else {
			if (consoleActive) toggleConsole(canvasPos.x - ARENA_BORDER - consoleSize.x);
		}

		if (consoleActive) {
			draw();
		}

		// counter for autoshooting interval
		boolean canShoot = false;
		if (autoShoot) {
			if (autoShootCount > 0) autoShootCount--;
			else {
				canShoot = true;
				autoShootCount = autoShootInterval;
			}
		}

		// trigger invincibility and autoshoot in all players when turned on
		if (oManager.players != null && (invincibility || autoShoot)) {
			for (Player p : oManager.players) {

				if (invincibility) p.INVINCIBLE = true;
				if (canShoot && !gManager.matchOver && p.ALIVE) {
					p.input.shootReleased = true;
					p.shoot();
				}

			}
		}

		// set the debug cursor position on input
		if (gManager.upPressed) {
			if (selectedOption > 0) selectedOption--;
			else selectedOption = debugOptions.length - 1;
			gManager.upPressed = false;
		}

		if (gManager.downPressed) {
			if (selectedOption < debugOptions.length - 1) selectedOption++;
			else selectedOption = 0;
			gManager.downPressed = false;
		}
	}

	void draw() {
		float indentFactor = 0.05;
		PVector textIndent = new PVector(consoleSize.x * indentFactor,consoleSize.y * indentFactor);
		PVector textPos = new PVector(consolePos.x + textIndent.x,consolePos.y + indentFactor + fontSize);
		float hSize = consoleSize.x - textIndent.x;
		String state = "VOID";

		// set up drawing
		noStroke();
		textSize(fontSize);
		textAlign(LEFT);

		// draw console background
		fill(colors.solid,consoleAlpha * 0.8);
		rect(consolePos.x,consolePos.y,consoleSize.x,consoleSize.y);

		// draw frame rate & other game variables
		fill(255,255,255,consoleAlpha);
		text("FPS " + (int)frameRate,textPos.x,textPos.y);
		text("CELLSIZE " + CELL_SIZE + " PX",textPos.x,textPos.y * 2);
		text("VIEW SIZE " + VIEW_WIDTH + " PX",textPos.x,textPos.y * 3);
		text("RESOLUTION " + floor(WIN_WIDTH) + " X " + floor(WIN_HEIGHT) + " PX",textPos.x,textPos.y * 4);
		text("FONTSIZE " + fontSize,textPos.x,textPos.y * 5);

		float gameStatsYPos = 7;

		text("GAMESTATS",textPos.x,textPos.y * gameStatsYPos);

		drawDivider(consolePos.x,textPos.y * gameStatsYPos,textIndent.x);

		text("PLAYERS " + oManager.activePlayers,textPos.x,textPos.y * (gameStatsYPos+1));
		text("SOLIDS " + oManager.solids.size(),textPos.x,textPos.y * (gameStatsYPos+2));
		text("NODES " + oManager.nodes.size(),textPos.x,textPos.y * (gameStatsYPos+3));
		text("BULLETS " + oManager.bullets.size(),textPos.x,textPos.y * (gameStatsYPos+4));
		text("LEVEL " + gManager.nextLevelID + "/" + levelList.size(),textPos.x,textPos.y * (gameStatsYPos+5));

		gameStatsYPos = 14;

		// switchable debug settings
		text("DEBUG SETTINGS",textPos.x,textPos.y * gameStatsYPos);

		drawDivider(consolePos.x,textPos.y * gameStatsYPos,textIndent.x);

		// step through the debug options array
		for (int i=0; i<debugOptions.length; i++) {

			String name = debugOptions[i].name;
			String active = "OFF";

			if (i == selectedOption) {

				name = "> " + debugOptions[i].name;

				// turn the option on or off
				if (gManager.leftPressed || gManager.rightPressed) {

					debugOptions[i].active = !debugOptions[i].active;
					gManager.leftPressed = false;
					gManager.rightPressed = false;

				}
			}

			if (debugOptions[i].active) active = "ON";
			else active = "OFF";

			text(name,textPos.x,textPos.y * (gameStatsYPos+i+1));
			text(active,textPos.x + hSize - hSize / 4,textPos.y * (gameStatsYPos+i+1));
		}
	}

	void toggleConsole(float _targetX) {

		// this function scales the console background width
		// and fades its alpha as well as the text alpha
		// using a nice easing effect

		// get the distance to the target and set a target dead zone
		float distanceX = _targetX - consolePos.x;
		float deadZoneX = _targetX * 0.2;

		// move the console until it reaches its target
		// using an easing factor of 0.2
		if (abs(distanceX) > abs(deadZoneX)) consolePos.x += distanceX * 0.2;
		else {

			consolePos.x = _targetX;

			// turn off console drawing when debug is turned off and the console finished moving away
			if (!gManager.debug) {
				consoleActive = false;
				println("Console Deactivated.");
			}
		}

		// get the difference of the current alpha and the target alpha
		int targetAlpha = 0;

		if (gManager.debug) targetAlpha = 255;
		else targetAlpha = 0;
		
		int alphaDistance = targetAlpha - consoleAlpha;

		// set the alpha
		if (abs(consoleAlpha) > targetAlpha) consoleAlpha += alphaDistance * 0.2;
		else consoleAlpha = targetAlpha;
	}

	void drawDivider(float _xPos, float _yPos, float _padding) {
		// set a padding
		float xPos = _xPos + _padding;
		float yPos = _yPos + (fontSize * 0.5);
		float hSize = consoleSize.x - (_padding * 2);

		// draw the divider line
		for (int x = 0; x <= hSize; x += fontSize / 2) {
			text("-",xPos + x, yPos);
		}		
	}

}
