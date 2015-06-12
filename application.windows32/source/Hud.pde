class Hud {
	int alpha;
	int blink;
	float rotation, statsDistance, easeControl, waitTime, waitDuration;
	boolean visible, showEndScreen;
	Pulser score = new Pulser();

	Hud() {
		blink = 0;
		rotation = 0;
		statsDistance = 0;
		easeControl = 0;
		showEndScreen = false;
		waitDuration = 100;
		waitTime = waitDuration;
	}

	void update() {
		// blinking timer
		int blinkDuration = 14;
		if (blink > 0) blink -= 1 * dtInSeconds;
		else {
			if (alpha < 255) {
				alpha = 255;
				rotation += radians(90);
				visible = true;
			}
			else {
				visible = false;
				alpha = 0;
			}

			blink = blinkDuration;
		}

		if (gManager.matchOver) {
			if (waitTime > 0) waitTime--;
			else {
				showEndScreen = true;
				waitTime = waitDuration;
			}
		} else showEndScreen = false;

		draw();
	}

	void draw() {	
		if (showEndScreen) {
		
			noStroke();
			fill(0,0,0,200);
			rect(0,0,WIN_WIDTH,WIN_HEIGHT);

			pushMatrix();

			translate(WIN_WIDTH / 2, WIN_HEIGHT / 2);

			//rotate the canvas to the winner
			switch (gManager.winnerID) {
				case 0: rotate(radians(180)); break;
				case 1: rotate(radians(0)); break;
				case 2: rotate(radians(270)); break;
				case 3: rotate(radians(90)); break;
			}

			drawStats();

			popMatrix();

		} else {

			for (int i=0; i<oManager.players.length; i++) {

				Player player = oManager.players[i];
				
				if (player.ALIVE) continue;
				else {
		
					pushMatrix();

					// set a pivot at the center of the view
					translate(WIN_WIDTH/2,WIN_HEIGHT/2);

					//rotate the canvas for each player
					switch (i) {
						case 0: rotate(radians(180)); break;
						case 1: rotate(radians(0)); break;
						case 2: rotate(radians(270)); break;
						case 3: rotate(radians(90)); break;
					}

					// set the draw color to the player color
					fill(colors.player[i],alpha);
					textAlign(CENTER);
					textSize(FONT_SIZE);

					// choose a text to draw
					String hudMessage;

					if (player.respawnTime > 0) hudMessage = "RESPAWN IN " + str(ceil(player.respawnTime));
					else if (player.spawnedOnce) hudMessage = "FIRE!";
					else hudMessage = "PRESS FIRE TO JOIN";
					
					// set the text position
					float textYPos = WIN_HEIGHT / 2 - ARENA_BORDER / 3;

					// draw the actual text
					text(hudMessage,0,textYPos);
					
					popMatrix();

				}
			}
		}
	}

	void drawStats() {
		drawBars();

		fill(colors.player[gManager.winnerID]);
		textAlign(CENTER);

		// header and footer setup
		String headerText = "";
		String footerText = "";

		if (!gManager.gameOver) {
			headerText = "ROUND OVER";
			footerText = "PRESS START TO CONTINUE";
		} else {
			headerText = "MATCH OVER";
			footerText = "PRESS START TO PLAY AGAIN";
		}

		// draw header
		textSize(FONT_SIZE * 4);
		text(headerText,0, -VIEW_HEIGHT / 2 + ARENA_BORDER * 1.5);

		// draw footer
		textSize(ARENA_BORDER);
		text(footerText,0,WIN_HEIGHT / 2 - ARENA_BORDER);
	}

	void drawBars() {
		String subText = "";
		float fontSizeL = FONT_SIZE * 3;
		float fontSizeS = FONT_SIZE;
		int playerWithMostWins = checkMostWins();
		int lineNumberCount = 0;
		int lineNumber = 0;

		PVector barSizeS	=	new PVector(WIN_HEIGHT * 0.4, VIEW_HEIGHT / 6);
		PVector barSizeL 	= 	new PVector(WIN_HEIGHT, barSizeS.y * 0.7);
		PVector barPos		=	new PVector(-WIN_HEIGHT / 2,0);
		float baseOffsetY	= 	-VIEW_HEIGHT / 4;
		float barsYSpacing 	= 	VIEW_HEIGHT / 32;
		int barsAlpha 		= 	200;
		float drawScale = score.pulse(3,1,0.8,0.5,1);
		
		rectMode(CENTER);

		for (int i=0; i<oManager.players.length; i++) {

			Player player = oManager.players[i];

			lineNumberCount++;

			// puts the player with the most wins in the first row
			if (i == playerWithMostWins) {
				lineNumber = 0;
				lineNumberCount--;
			} else lineNumber = lineNumberCount; 
			
			// set the bars y position
			barPos.y = baseOffsetY + (barsYSpacing + barSizeS.y) * lineNumber;

			// draw bars
			noStroke();
			fill(colors.solid,barsAlpha);
			rect(0, barPos.y, barSizeL.x, barSizeL.y);
			fill(colors.player[i],barsAlpha);
			rect(barPos.x + barSizeS.x / 2, barPos.y, barSizeS.x, barSizeS.y);
			
			// check the players stats and choose a fitting text
			String[] playerName = new String[]{"RED","YELLOW","GREEN","BLUE"};
			subText = playerName[i] + " " + getDescription(i);

			// set the subtext position
			PVector subTextPos	= new PVector(barPos.x + barSizeS.x + barSizeL.x / 16, barPos.y + fontSizeS * 0.25);

			fill(colors.player[i]);
			textSize(fontSizeS);
			textAlign(LEFT);			
			text(subText,subTextPos.x,subTextPos.y);

			// set up the position and size of the squares to draw
			float boxSize = barSizeS.y * 0.333;
			float boxSpacing = barSizeS.y * 0.333;
			float offsetX = barSizeS.x / 2 - boxSize - boxSpacing;
			PVector pos = new PVector(barPos.x + offsetX, barPos.y);

			stroke(colors.solid);
			strokeWeight(barSizeS.y * 0.05);

			// draw the squares
			for (int b=0; b<3; b++) {

				float alp = 255;
				float dScale = 1;

				// draw size
				if (player.id == gManager.winnerID && b == player.wins-1) {
					dScale = drawScale;
					alp = map(drawScale,1,3,255,0);
				}

				//set the color and alpha
				if (b < player.wins) {
					fill(colors.player[i],alp);
					stroke(colors.solid,alp);
				} else {
					fill(colors.solid,200);
					stroke(colors.solid,255);
				}

				offsetX = b * (boxSize + boxSpacing);
				rect(pos.x + offsetX, pos.y, boxSize * dScale, boxSize * dScale);
			}
		}
	}

	String getDescription(int _playerID) {
		
		int winnerID = 100;
		int shots = 0; 
		int kills = 0; 
		int deaths = 0; 
		int items = 0;
		int mostShots = 100; 
		int mostKills = 100; 
		int mostDeaths = 100; 
		int mostItems = 100;
		String text = "";

		for (Player p : oManager.players) {

			// if the player is the winner, set the message and skip the rest of the loop
			if (p.id == gManager.winnerID) {
				winnerID = p.id;
				continue;
			}

			// otherwise check 
			if (p.shots > shots) {
				shots = p.shots;
				mostShots = p.id;
			}
			if (p.kills > kills) {
				shots = p.kills;
				mostKills = p.id;
			}
			if (p.deaths > deaths) {
				deaths = p.deaths;
				mostDeaths = p.id;
			}
			if (p.items > items) {
				items = p.items;
				mostItems = p.id;
			}
		}

		if (winnerID == _playerID) {
			if (!gManager.gameOver) text = "WON THE MATCH!";
			else text = "WON THE GAME!";
		} else if (mostShots == _playerID) text = "FIRED THE MOST SHOTS!";
		else if (mostKills == _playerID) text = "GOT THE MOST KILLS!";
		else if (mostDeaths == _playerID) text = "DIED MOST OFTEN!";
		else if (mostItems == _playerID) text = "GOT THE MOST ITEMS!";
		else text = "DIDN'T PLAY.";

		return text;
	}

	void showPlayerEndScreen(int _playerID, float _xPos, float _yPos) {
	}

	int checkMostWins() {
		int wins = 0;
		int mostWins = 0;

		for (Player p : oManager.players) {
			if (p.wins > wins) {
				wins = p.wins;
				mostWins = p.id;
			}
		}

		return mostWins;
	}
}
