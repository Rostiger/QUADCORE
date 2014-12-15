class GameManager {
	float prevMillis;

	boolean debug = false;
	boolean gameOver = false;
	boolean matchOver = false;
	boolean canRestart = false;
	boolean drawCheckers = false;

	boolean upPressed, downPressed, leftPressed, rightPressed, enterPressed;

	int winnerID;
	int prevLevelID;
	int nextLevelID;

	Checkers checkers = new Checkers();

	GameManager() {
	    prevLevelID = 100;
    	prevMillis = millis();
	}

	void reset() {
		// make sure all game objects (except players) are removed
		oManager.clearGameObjects();
		
		// pick a color scheme
		colors.pickColorScheme("DARK_PURPLE");

		// choose a random new level from the list of available levels
		nextLevelID = (int)random(0,levelList.size());
		// never pick the same level again after it has been played
		while (nextLevelID == prevLevelID) nextLevelID = (int)random(0,levelList.size());

		// determine level proportions depending on the amount of characters in the first line of the level file
		float border =  ARENA_BORDER * 2;
		CELL_SIZE = floor((WIN_HEIGHT - border) / (levelList.get(nextLevelID).width));
		VIEW_WIDTH = ceil(CELL_SIZE * levelList.get(nextLevelID).width);
		VIEW_HEIGHT = ceil(CELL_SIZE * levelList.get(nextLevelID).width);

		// parse the level
		levelParser.parseLevel(nextLevelID);

		prevLevelID = nextLevelID;

		// reset the players
		oManager.resetPlayers();

		// reset the game state
		gameOver = false;
		matchOver = false;
		
	    // finally add a new hud and collision class
	    // these come after parsing the level, because they are dependend on the CELL_SIZE value
		hud = new Hud();
		collision = new Collision();
	}

	void update() {
		// DELTA TIME
		// millis() returns the milliseconds passed since starting the program
		// get the duration of the lastFrame by subtracting the value of millis()
		// from the last frame by the current value of millis()
		float lastFrameDuration = millis() - prevMillis;
		prevMillis = millis();
		
		// save dt in seconds
		dtInSeconds = lastFrameDuration / 1000;

		// draw a checkerboard for the winner
		if (matchOver || drawCheckers) checkers.drawCheckers();

		// update game objects
		oManager.update();

		// update HUD
		if (hud != null) hud.update();
	}

	void keyPressed() {
		oManager.keyPressed();

		if (debug) {
			if (keyCode == UP) upPressed = true;
			if (keyCode == DOWN) downPressed = true;
			if (keyCode == LEFT) leftPressed = true;
			if (keyCode == RIGHT) rightPressed = true;
			if (keyCode == ENTER) enterPressed = true;
		}
	}

	void keyReleased() {
		oManager.keyReleased();

		//toggle debug mode
		if (key == '~' || key == '`' || key == '^') {
			if (!debug) debug = true;
			else debug = false;
		}

		//reset game
		if (!debug && keyCode == ENTER) reset();
	}
}