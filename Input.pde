class Input {
	
	int id;
	boolean hasGamePad;

    boolean upSlider, downSlider, leftSlider, rightSlider;
    boolean upButton, downButton, leftButton, rightButton;
    boolean upHat, downHat, leftHat, rightHat;

	boolean upPressed, upWasPressed, upReleased;
	boolean downPressed, downWasPressed, downReleased;
	boolean leftPressed, leftWasPressed, leftReleased;
	boolean rightPressed, rightWasPressed, rightReleased;
	boolean shootPressed, shootWasPressed, shootReleased;
	boolean useItemPressed, useItemWasPressed, useItemReleased;
	boolean startPressed, startWasPressed, startReleased;
	boolean anyKeyPressed, anyKeyWasPressed, anyKeyReleased;
	boolean north, east, south, west;

	ControlDevice gamePad;

	Input(int _id) {
		id = _id;

		upSlider = false; downSlider = false; leftSlider = false; rightSlider = false;
		upButton = false; downButton = false; leftButton = false; rightButton = false;
		upHat = false; downHat = false; leftHat = false; rightHat = false;

		upPressed		=	false; upWasPressed 	 	= false; upReleased 		= false;
		downPressed		=	false; downWasPressed 	 	= false; downReleased 		= false;
		leftPressed		=	false; leftWasPressed 		= false; leftReleased 		= false;
		rightPressed	=	false; rightWasPressed 		= false; rightReleased 		= false;
		shootPressed	=	false; shootWasPressed 		= false; shootReleased 		= false;
		useItemPressed	=	false; useItemWasPressed 	= false; useItemReleased 	= false;
		startPressed	=	false; startWasPressed 		= false; startReleased 		= false;
		anyKeyPressed 	= 	false;

		north = false;
		east = false;
		south = false;
		west = false;

		// check if player is using a game pad
		for ( int i = 0; i < gPads.size(); i++ ) {
			if (i == id) {
				hasGamePad = true;
				break;
			} else hasGamePad = false;
		}

		if (hasGamePad) gamePad = gPads.get(id);
	}

	void update() {
		manageInputStates();
		if (hasGamePad) getGamePadInput(id);
		if (TOP_VIEW) setDirections();
		else {
			if (upPressed) north = true;
			else north = false;
			if (downPressed) south = true;
			else south = false;
			if (leftPressed) west = true;
			else west = false;
			if (rightPressed) east = true;
			else east = false;
		}
	}

	void setDirections() {
		// sets the directions for each player
		if (upPressed) {
			switch (id) {
				case 0: south = true; break;
				case 1: north = true; break;
				case 2: west = true; break;
				case 3: east = true; break;
			}
		} else {
			switch (id) {
				case 0: south = false; break;
				case 1: north = false; break;
				case 2: west = false; break;
				case 3: east = false; break;
			}				
		}

		if (downPressed) {
			switch (id) {
				case 0: north = true; break;
				case 1: south = true; break;
				case 2: east = true; break;
				case 3: west = true; break;
			}
		}
		else {
			switch (id) {
				case 0: north = false; break;
				case 1: south = false; break;
				case 2: east = false; break;
				case 3: west = false; break;
			}
		}

		if (leftPressed) {
			switch (id) {
				case 0: east = true; break;
				case 1: west = true; break;
				case 2: south = true; break;
				case 3: north = true; break;
			}
		}
		else {
			switch (id) {
				case 0: east = false; break;
				case 1: west = false; break;
				case 2: south = false; break;
				case 3: north = false; break;
			}
		}

		if (rightPressed) {
			switch (id) {
				case 0: west = true; break;
				case 1: east = true; break;
				case 2: north = true; break;
				case 3: south = true; break;
			}
		}
		else {
			switch (id) {
				case 0: west = false; break;
				case 1: east = false; break;
				case 2: north = false; break;
				case 3: south = false; break;
			}
		}
	}

	void getGamePadInput(int _id) {
		int id = _id;

        if (gamePad.getSlider("LS_Y") != null)          upSlider        = gamePad.getSlider("LS_Y").getValue() < -0.2 ? true : false;
        if (gamePad.getButton("DP_UP") != null)         upButton        = gamePad.getButton("DP_UP").pressed();
        if (gamePad.getHat("DPAD") != null)             upHat           = gamePad.getHat("DPAD").up();

        if (gamePad.getSlider("LS_Y") != null)          downSlider      = gamePad.getSlider("LS_Y").getValue() > 0.2 ? true : false;
        if (gamePad.getButton("DP_UP") != null)         downButton      = gamePad.getButton("DP_DOWN").pressed();
        if (gamePad.getHat("DPAD") != null)             downHat         = gamePad.getHat("DPAD").down();

        if (gamePad.getSlider("LS_Y") != null)          leftSlider      = gamePad.getSlider("LS_X").getValue() < -0.2 ? true : false;
        if (gamePad.getButton("DP_LEFT") != null)       leftButton      = gamePad.getButton("DP_LEFT").pressed();
        if (gamePad.getHat("DPAD") != null)             leftHat         = gamePad.getHat("DPAD").left();

        if (gamePad.getSlider("LS_Y") != null)          rightSlider = gamePad.getSlider("LS_X").getValue() > 0.2 ? true : false;
        if (gamePad.getButton("DP_RIGHT") != null)      rightButton = gamePad.getButton("DP_RIGHT").pressed();
        if (gamePad.getHat("DPAD") != null)             rightHat    = gamePad.getHat("DPAD").right();

        upPressed       = (upSlider     || upButton     || upHat)       ? true : false;
        downPressed     = (downSlider   || downButton   || downHat)     ? true : false;
        leftPressed     = (leftSlider   || leftButton   || leftHat)     ? true : false;
        rightPressed    = (rightSlider  || rightButton  || rightHat)    ? true : false;

        shootPressed    = gPads.get(id).getButton("BT_A").pressed();
        useItemPressed  = gPads.get(id).getButton("BT_B").pressed();
        startPressed    = gPads.get(id).getButton("BT_C").pressed();

		// handle any key boolean
		if (upPressed || downPressed || leftPressed || rightPressed || shootPressed || useItemPressed || startPressed) anyKeyPressed = true;
		else anyKeyPressed = false;
	}

	void manageInputStates() {
		// take care of button presses/states
		if (upPressed) { upWasPressed = true; upReleased = false; }
		else {
			if (upWasPressed) upReleased = true;
			else upReleased = false;
			upWasPressed = false;
		}

		if (downPressed) { downWasPressed = true; downReleased = false; }
		else {
			if (downWasPressed) downReleased = true;
			else downReleased = false;
			downWasPressed = false;
		}

		if (leftPressed) { leftWasPressed = true; leftReleased = false; }
		else {
			if (leftWasPressed) leftReleased = true;
			else leftReleased = false;
			leftWasPressed = false;
		}

		if (rightPressed) { rightWasPressed = true; rightReleased = false; }
		else {
			if (rightWasPressed) rightReleased = true;
			else rightReleased = false;
			rightWasPressed = false;
		}

		if (shootPressed) { shootWasPressed = true; shootReleased = false; }
		else {
			if (shootWasPressed) shootReleased = true;
			else shootReleased = false;
			shootWasPressed = false;
		}

		if (useItemPressed) { useItemWasPressed = true; useItemReleased = false; }
		else {
			if (useItemWasPressed) useItemReleased = true;
			else useItemReleased = false;
			useItemWasPressed = false;
		}
		
		if (startPressed) { startWasPressed = true; startReleased = false; }
		else {
			if (startWasPressed) startReleased = true;
			else startReleased = false;
			startWasPressed = false;
		}
	}

	void keyPressed() {
		switch(id) {
			case 0:
				if (keyCode == UP) upPressed = true;
				if (keyCode == DOWN) downPressed = true;
				if (keyCode == LEFT) leftPressed = true;
				if (keyCode == RIGHT) rightPressed = true;
				if (key == '/') shootPressed = true;
				if (keyCode == SHIFT) useItemPressed = true;
				if (key == ' ') startPressed = true;
			break;
			case 1:
				if (key == 'w') upPressed = true;
				if (key == 's') downPressed = true;
				if (key == 'a') leftPressed = true;
				if (key == 'd') rightPressed = true;
				if (key == 'f') shootPressed = true;
				if (key == 'r') useItemPressed = true;
				if (key == 'q') startPressed = true;
			break;
			case 2:
				if (key == 'i') upPressed = true;
				if (key == 'k') downPressed = true;
				if (key == 'j') leftPressed = true;
				if (key == 'l') rightPressed = true;
				if (key == 'h') shootPressed = true;
				if (key == 'y') useItemPressed = true;
				if (key == 'o') startPressed = true;
			break;
			case 3:
				if (key == '8') upPressed = true;
				if (key == '5') downPressed = true;
				if (key == '4') leftPressed = true;
				if (key == '6') rightPressed = true;
				if (key == '0') shootPressed = true;
				if (key == '1') useItemPressed = true;
				if (key == '2') startPressed = true;
			break;
		}
		if (upPressed || downPressed || leftPressed || rightPressed || shootPressed || useItemPressed || startPressed) anyKeyPressed = true;
	}

	void keyReleased() {
		switch(id) {
			case 0:
				if (keyCode == UP) upPressed = false;
				if (keyCode == DOWN) downPressed = false;
				if (keyCode == LEFT) leftPressed = false;
				if (keyCode == RIGHT) rightPressed = false;
				if (key == '/') shootPressed = false;
				if (keyCode == SHIFT) useItemPressed = false;
				if (key == ' ') startPressed = false;
			break;
			case 1:
				if (key == 'w') upPressed = false;
				if (key == 's') downPressed = false;
				if (key == 'a') leftPressed = false;
				if (key == 'd') rightPressed = false;
				if (key == 'f') shootPressed = false;
				if (key == 'r') useItemPressed = false;
				if (key == 'q') startPressed = false;
			break;
			case 2:
				if (key == 'i') upPressed = false;
				if (key == 'k') downPressed = false;
				if (key == 'j') leftPressed = false;
				if (key == 'l') rightPressed = false;
				if (key == 'h') shootPressed = false;
				if (key == 'y') useItemPressed = false;
				if (key == 'o') startPressed = false;
			break;
			case 3:
				if (key == '8') upPressed = false;
				if (key == '5') downPressed = false;
				if (key == '4') leftPressed = false;
				if (key == '6') rightPressed = false;
				if (key == '0') shootPressed = false;
				if (key == '1') useItemPressed = false;
				if (key == '2') startPressed = false;
			break;
		}
		if (!upPressed || !downPressed || !leftPressed || !rightPressed || !shootPressed || !useItemPressed || !startPressed) anyKeyPressed = false;
	}
}