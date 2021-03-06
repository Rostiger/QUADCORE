class GameManager {
	float prevMillis;

	boolean debug = false;
	boolean paused = false;
	boolean gameOver = false;
	boolean matchOver = false;

	int winnerID;
	int prevLevelID;
	int nextLevelID;
	int alpha;

	Grid grid;
	Pulser gridPulser;

	GameManager() {
	    prevLevelID = 100;
    	prevMillis = millis();
    	grid = new Grid();
    	gridPulser = new Pulser();
    	alpha = 0;
   	}

	void reset() {
		// this method removes all active game objects and loads a new level
		// since levels can have variable dimensions, the grid and the cellsizes are re-calculated on every level load

		// make sure all game objects (except players) are removed
		oManager.clearGameObjects();

		// pick a color scheme
		colors.pickColorScheme(COLOR_SCHEME);

		// choose a random new level from the list of available levels
		nextLevelID = (int)random(0,levelList.size());
		// make sure to never pick the same level again after it has just been played
		while (nextLevelID == prevLevelID) nextLevelID = (int)random(0,levelList.size());

		// determine level proportions depending on the height of the level file (levels always need to be square, so width or height is the same)
		CELL_SIZE = floor((WIN_HEIGHT - ARENA_BORDER * 2) / levelList.get(nextLevelID).height);
		VIEW_HEIGHT = CELL_SIZE * levelList.get(nextLevelID).height;
		VIEW_WIDTH = VIEW_HEIGHT;

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
	    // these come after parsing the level, because they are dependent on the CELL_SIZE value
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

		// update game objects
		if (menu.active) menu.update();
		else {
			oManager.update();
			hud.update();

			// // store a background image when paused
			if (paused) {
				menu.bg = canvas.get();
				menu.active = true;
			} updateGrid();			
		}
	}

	void updateGrid() {
		// grid (pos, siz, cellSize, pointSize, pointWeight, color, alpha)
		pushMatrix();
		translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);
		PVector gridPos = new PVector(-VIEW_WIDTH / 2, -VIEW_HEIGHT / 2);
		PVector gridSiz = new PVector(VIEW_WIDTH , VIEW_HEIGHT);

        // change the grid color to the winner
        float drawScale = 1;
        int gridColor = colors.item;
        int alp = 50;
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE, CELL_SIZE / 8 * drawScale, 1 * drawScale, gridColor, alp);
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE * 4, CELL_SIZE / 2 * drawScale, 1 * drawScale, gridColor, alp);
		popMatrix();
	}
}