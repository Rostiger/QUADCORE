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
		// make sure all game objects (except players) are removed
		oManager.clearGameObjects();

		// pick a color scheme
		colors.pickColorScheme("DARK_PURPLE");

		// choose a random new level from the list of available levels
		nextLevelID = (int)random(0,levelList.size());
		// never pick the same level again after it has been played
		while (nextLevelID == prevLevelID) nextLevelID = (int)random(0,levelList.size());

		// determine level proportions depending on the amount of characters in the first line of the level file
		CELL_SIZE = floor((WIN_HEIGHT - ARENA_BORDER * 2) / levelList.get(nextLevelID).height);
		VIEW_HEIGHT = CELL_SIZE * levelList.get(nextLevelID).height;
		VIEW_WIDTH = VIEW_HEIGHT;
		canvas = createGraphics(VIEW_WIDTH,VIEW_HEIGHT);
		canvasPos = new PVector(WIN_WIDTH / 2 - VIEW_WIDTH / 2, ARENA_BORDER);

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

			// if (matchOver || debugger.drawCheckers) {
			// 	blink(100,0,5);
			// 	fill(colors.player[winnerID], alpha);
			// 	noStroke();
			// 	rectMode(CENTER);
			// 	canvas.rect(WIN_WIDTH / 2,WIN_HEIGHT / 2,VIEW_WIDTH, VIEW_HEIGHT);
			// }
			oManager.update();
			hud.update();

			// store a background image when paused
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
		// if (matchOver || debugger.drawWinnerGrid) {
		// 	gridColor = colors.player[winnerID];
		// 	drawScale = gridPulser.pulse(1,8,0.5,1,-1);
		// 	alp = 150;
		// }
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE, CELL_SIZE / 8 * drawScale, 1 * drawScale, gridColor, alp);
		grid.drawGrid(gridPos, gridSiz, CELL_SIZE * 4, CELL_SIZE / 2 * drawScale, 1 * drawScale, gridColor, alp);
		popMatrix();
	}
}
