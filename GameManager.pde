class GameManager {
	float prevMillis;

	boolean debug = false;
	boolean paused = false;
	boolean gameOver = false;
	boolean matchOver = false;

	int winnerID;
	int prevLevelID;
	int nextLevelID;

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
		CELL_SIZE = VIEW_HEIGHT / (levelList.get(nextLevelID).height);

		// parse the level
		levelParser.parseLevel(nextLevelID);

		// print some level info
		println("Level No." + nextLevelID + " | " + "Cellsize: " + CELL_SIZE + " | " + "Levelsize: " + levelList.get(nextLevelID).width + " x " + levelList.get(nextLevelID).width );

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
		checkers = new Checkers();
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

		// update game objects
		if (menu.active) menu.update();
		else {
		
			oManager.update();
			hud.update();
			
			// store a background image when paused
			if (paused) {
				menu.bg = get();
				menu.active = true;
			}

		}
	}

}