class GameManager {
	float prevMillis;

	boolean debug = false;
	boolean gameOver = false;
	boolean matchOver = false;
	boolean canRestart = false;

	boolean upPressed, downPressed, leftPressed, rightPressed, enterPressed;

	int maxPlayers = 4;
	Player[] players = new Player[maxPlayers];
	PVector[] playerStartPos = new PVector[maxPlayers];

	int winnerID;
	int prevLevelID;
	int nextLevelID;

	int activePlayers;

	Checkers checkers = new Checkers();

	GameManager() {
	    prevLevelID = 100;
    	prevMillis = millis();

		// the amount of currently active players
		activePlayers = 0;
	}

	void reset() {
		
		// pick a color scheme
		colors.pickColorScheme("DARK_PURPLE");

		oManager = new ObjectManager();

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

		// add inactive players if they aren't there already
		addPlayers();
		resetPlayers();

		// reset the game state
		gameOver = false;
		matchOver = false;
		
	    // finally add a new hud and collision class
	    // these come after parsing the level, because they are dependend on the CELL_SIZE value
		hud = new Hud();
		collision = new Collision();
	}

	void setPlayerStartPosition(int _id, PVector _pos) {
		// when the level is parsed, the position for every player is stored in
		// an array, so it can be used when the player joins the game
		playerStartPos[_id] = new PVector( _pos.x, _pos.y );
	}

	void addPlayers() {
		for (int i=0; i<maxPlayers; i++) {
			if (players[i] != null) continue;
			else {
				Player p = new Player(i);
				players[i] = p;
			}
		}
	}

	void resetPlayers() {
		for (Player p : players) p.reset();
	}

	void update() {
		// DELTA TIME
		// millis() returns the milliseconds passed since starting the program
		// get the duration of the lastFrame by subtracting the value of millis()
		// from the last frame by the current value of millis()
		float lastFrameDuration = millis() - prevMillis;
		prevMillis = millis();
		
		// save dt in jan format
		dt = lastFrameDuration / 1000 * 60;
		// save dt in seconds
		dtInSeconds = lastFrameDuration / 1000;


		// draw a checkerboard for the winner
		if (matchOver) checkers.drawCheckers();

		// update bullets and targets
		oManager.update();

		// update all players
		if (players != null) {
			for (Player p : players) {
				p.update();
				// restart the game when the game is over and start was pressed
				if (matchOver && p.input.startPressed) reset();
			}
		}

		// update HUD
		if (hud != null) hud.update();
	}

	void keyPressed() {
		//check keyPresses for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.checkKeyPress();
			}
		}

		if (debug) {
			if (keyCode == UP) upPressed = true;
			if (keyCode == DOWN) downPressed = true;
			if (keyCode == LEFT) leftPressed = true;
			if (keyCode == RIGHT) rightPressed = true;
			if (keyCode == ENTER) enterPressed = true;
		}
	}

	void keyReleased() {
		//check keyReleases for all players if the aren't using a gamepad
		if (players != null) {
			for (Player p : players) {
				if (p.input.hasGamePad) continue;
				else p.input.checkKeyRelease();
			}
		}

		//toggle debug mode
		if (key == '~' || key == '`' || key == '^') {
			if (!debug) debug = true;
			else debug = false;
		}

		//reset game
		if (!debug && keyCode == ENTER) reset();

	}
}